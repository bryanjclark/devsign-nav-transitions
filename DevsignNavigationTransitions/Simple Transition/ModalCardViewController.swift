//
//  ModalCardViewController.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/7/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit
import Cartography

// When animating in/out of ModalCardViewController,
// we need to know what type of transition is going on,
// so we can animate properly.
fileprivate enum ModalTransitionType {
	case presentation, dismissal
}

class ModalCardViewController: UIViewController {
	private let cardView = UIView()
	private let dismissButton = UIButton()
	private let dismissTapView = UIView()
	fileprivate var currentModalTransitionType: ModalTransitionType? = nil

	fileprivate static let overlayBackgroundColor = UIColor.black.withAlphaComponent(0.4)

	init() {
		super.init(nibName: nil, bundle: nil)

		self.transitioningDelegate = self
		self.modalPresentationStyle = .overFullScreen
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = ModalCardViewController.overlayBackgroundColor

		// If you tap the gray background, the card dismisses
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissButtonTapped))
		self.dismissTapView.addGestureRecognizer(tapGesture)
		self.view.addSubview(self.dismissTapView)
		constrain(self.dismissTapView) { $0.edges == $0.superview!.edges }

		// Let's add the rounded-corner white card
		self.cardView.backgroundColor = .white
		self.cardView.layer.cornerRadius = 12
		self.cardView.clipsToBounds = true
		self.view.addSubview(self.cardView)
		constrain(self.cardView) {
			$0.leading == $0.superview!.safeAreaLayoutGuide.leading + 8
			$0.trailing == $0.superview!.safeAreaLayoutGuide.trailing - 8
			$0.bottom == $0.superview!.safeAreaLayoutGuide.bottom - 8
			$0.height == 300
		}

		// ...and the dismiss button
		self.dismissButton.setTitle("Dismiss", for: .normal)
		self.dismissButton.setTitleColor(self.view.tintColor, for: .normal)
		self.dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
		self.cardView.addSubview(self.dismissButton)
		constrain(self.dismissButton) {
			$0.leading == $0.superview!.leading
			$0.trailing == $0.superview!.trailing
			$0.bottom == $0.superview!.bottom
			$0.height == 50
		}
    }

	@objc private func dismissButtonTapped() {
		self.presentingViewController?.dismiss(animated: true, completion: nil)
	}
}

extension ModalCardViewController: UIViewControllerTransitioningDelegate {
	public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if presented == self {
			self.currentModalTransitionType = .presentation
			return self
		} else {
			return nil
		}
	}

	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		if dismissed == self {
			self.currentModalTransitionType = .dismissal
			return self
		} else {
			return nil
		}
	}
}

extension ModalCardViewController: UIViewControllerAnimatedTransitioning {
	private var transitionDuration: TimeInterval {
		return 0.4
	}

	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return transitionDuration
	}

	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let transitionType = self.currentModalTransitionType else { fatalError() }
		self.currentModalTransitionType = nil

		let offscreenSituation = {
			let offscreenY = self.view.bounds.height - self.cardView.frame.minY + 20
			self.cardView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offscreenY)
			self.view.backgroundColor = .clear
		}

		let presentedSituation = {
			self.cardView.transform = CGAffineTransform.identity
			self.view.backgroundColor = ModalCardViewController.overlayBackgroundColor
		}

		let damping: CGFloat = 0.9
		let animator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: damping)

		switch transitionType {
		case .presentation:
			let toView = transitionContext.view(forKey: .to)!
			UIView.performWithoutAnimation(offscreenSituation)
			transitionContext.containerView.addSubview(toView)
			animator.addAnimations(presentedSituation)
		case .dismissal:
			animator.addAnimations(offscreenSituation)
		}
		animator.addCompletion { (position) in
			assert(position == .end)
			transitionContext.completeTransition(true)
		}

		animator.startAnimation()
	}
}
