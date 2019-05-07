//
//  ModalCardViewController.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/7/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

// When animating in/out of ModalCardViewController,
// we need to know what type of transition is going on,
// so we can animate properly.
fileprivate enum ModalTransitionType {
	case presentation, dismissal
}

class ModalCardViewController: UIViewController {
	private let cardView = UIView()
	private let dismissButton = UIButton()
	fileprivate var currentModalTransitionType: ModalTransitionType? = nil

	fileprivate static let overlayBackgroundColor = UIColor.black.withAlphaComponent(0.4)

	init() {
		super.init(nibName: nil, bundle: nil)

		self.modalTransitionStyle = .crossDissolve
		self.transitioningDelegate = self
		self.modalPresentationStyle = .overFullScreen
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = ModalCardViewController.overlayBackgroundColor

		self.cardView.backgroundColor = .white
		self.cardView.layer.cornerRadius = 12
		self.cardView.clipsToBounds = true
		self.view.addSubview(self.cardView)

		self.dismissButton.setTitle("Dismiss", for: .normal)
		self.dismissButton.setTitleColor(self.view.tintColor, for: .normal)
		self.dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
		self.cardView.addSubview(self.dismissButton)
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		let cardHeight = (self.view.bounds.height / 2) - 16
		self.cardView.frame = CGRect(
			x: self.view.layoutMargins.left,
			y: self.view.bounds.height - cardHeight - 24,
			width: self.view.bounds.width - self.view.layoutMargins.left - self.view.layoutMargins.right,
			height: cardHeight
		)

		self.dismissButton.frame = CGRect(
			x: 0,
			y: self.cardView.bounds.height - 50,
			width: self.cardView.bounds.width,
			height: 50
		)
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

		let damping: CGFloat = 0.8
		let animator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: damping)

		switch transitionType {
		case .presentation:
			let toView = transitionContext.view(forKey: .to)!
			UIView.performWithoutAnimation(offscreenSituation)
			transitionContext.containerView.addSubview(toView)
			animator.addAnimations(presentedSituation)
		case .dismissal:
			animator.addAnimations {
				self.cardView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: self.view.bounds.height - self.cardView.frame.minY + 20)
			}
//			animator.addAnimations(offscreenSituation)
		}
		animator.addCompletion { (position) in
			assert(position == .end)
			transitionContext.completeTransition(true)
		}

		animator.startAnimation()
	}
}
