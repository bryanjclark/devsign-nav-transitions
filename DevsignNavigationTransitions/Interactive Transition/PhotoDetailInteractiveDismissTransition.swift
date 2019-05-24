//
//  PhotoDetailInteractiveDismissTransition.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/23/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

/// Manages the interactive transition animation for the drag-to-dismiss gesture
/// in Locket Photos — designed to mimic the same gesture from Apple's Photos app.

public class PhotoDetailInteractiveDismissTransition: NSObject {
	/// The from- and to- viewControllers can conform to the protocol in order to get updates and vend snapshotViews
	fileprivate let fromDelegate: PhotoDetailTransitionAnimatorDelegate
	fileprivate weak var toDelegate: PhotoDetailTransitionAnimatorDelegate?

	/// The background animation is the "photo-detail background opacity goes to zero"
	fileprivate var backgroundAnimation: UIViewPropertyAnimator? = nil

	// NOTE: To avoid writing tons of boilerplate that pulls these values out of
	// the transitionContext, I'm just gonna cache them here.
	fileprivate var transitionContext: UIViewControllerContextTransitioning? = nil
	fileprivate var fromReferenceImageViewFrame: CGRect? = nil
	fileprivate var toReferenceImageViewFrame: CGRect? = nil
	fileprivate weak var fromVC: PhotoDetailViewController? = nil
	fileprivate weak var toVC: UIViewController? = nil

	/// The snapshotView that is animating between the two view controllers.
	fileprivate let transitionImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.accessibilityIgnoresInvertColors = true
		return imageView
	}()

	init(fromDelegate: PhotoDetailViewController, toDelegate: Any) {
		self.fromDelegate = fromDelegate
		self.toDelegate = toDelegate as? PhotoDetailTransitionAnimatorDelegate

		super.init()
	}

	/// Called by the photo-detail screen, this function updates the state of
	/// the interactive transition, based on the state of the gesture.
	func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
		let transitionContext = self.transitionContext!
		let transitionImageView = self.transitionImageView
		let translation = gestureRecognizer.translation(in: nil)
		let translationVertical = translation.y

		// For a given vertical-drag, we calculate our percentage complete
		// and how shrunk-down the transition-image should be.
		let percentageComplete = self.percentageComplete(forVerticalDrag: translationVertical)
		let transitionImageScale = transitionImageScaleFor(percentageComplete: percentageComplete)

		switch gestureRecognizer.state {
		case .possible, .began:
			break
		case .cancelled, .failed:
			self.completeTransition(didCancel: true)

		case .changed:
			transitionImageView.transform = CGAffineTransform.identity
				.scaledBy(x: transitionImageScale, y: transitionImageScale)
				.translatedBy(x: translation.x, y: translation.y)

			transitionContext.updateInteractiveTransition(percentageComplete)
			self.backgroundAnimation?.fractionComplete = percentageComplete

		case .ended:
			// Here, we decide whether to complete or cancel the transition.
			let fingerIsMovingDownwards = gestureRecognizer.velocity(in: nil).y > 0
			let transitionMadeSignificantProgress = percentageComplete > 0.1
			let shouldComplete = fingerIsMovingDownwards && transitionMadeSignificantProgress
			self.completeTransition(didCancel: !shouldComplete)
		@unknown default:
			break
		}
	}

	private func completeTransition(didCancel: Bool) {
		// If the gesture was cancelled, we reverse the "fade out the photo-detail background" animation.
		self.backgroundAnimation?.isReversed = didCancel

		let transitionContext = self.transitionContext!
		let backgroundAnimation = self.backgroundAnimation!

		// The cancel and complete animations have different timing values.
		// I dialed these in on-device using SwiftTweaks.
		let completionDuration: Double
		let completionDamping: CGFloat
		if didCancel {
			completionDuration = 0.45
			completionDamping = 0.75
		} else {
			completionDuration = 0.37
			completionDamping = 0.90
		}

		// The transition-image needs to animate into its final place.
		// That's either:
		// - its original spot on the photo-detail screen (if the transition was cancelled),
		// - or its place in the photo-grid (if the transition completed).
		let foregroundAnimation = UIViewPropertyAnimator(duration: completionDuration, dampingRatio: completionDamping) {
			// Reset our scale-transform on the imageview
			self.transitionImageView.transform = CGAffineTransform.identity

			// NOTE: It's important that we ask the toDelegate *here*,
			// because if the device has rotated,
			// the toDelegate needs a chance to update its layout
			// before asking for the frame.
			self.transitionImageView.frame = didCancel
				? self.fromReferenceImageViewFrame!
				: self.toDelegate?.imageFrame() ?? self.toReferenceImageViewFrame!
		}

		// When the transition-image has moved into place, the animation completes,
		// and we close out the transition itself.
		foregroundAnimation.addCompletion { [weak self] (position) in
			self?.transitionImageView.removeFromSuperview()
			self?.transitionImageView.image = nil
			self?.toDelegate?.transitionDidEnd()
			self?.fromDelegate.transitionDidEnd()

			if didCancel {
				transitionContext.cancelInteractiveTransition()
			} else {
				transitionContext.finishInteractiveTransition()
			}
			transitionContext.completeTransition(!didCancel)
			self?.transitionContext = nil
		}

		// Update the backgroundAnimation's duration to match.
		// PS: How *cool* are property-animators? I say: very. This "continue animation" bit is magic!
		let durationFactor = CGFloat(foregroundAnimation.duration / backgroundAnimation.duration)
		backgroundAnimation.continueAnimation(withTimingParameters: nil, durationFactor: durationFactor)
		foregroundAnimation.startAnimation()
	}

	/// For a given vertical offset, what's the percentage complete for the transition?
	/// e.g. -100pts -> 0%, 0pts -> 0%, 20pts -> 10%, 200pts -> 100%, 400pts -> 100%
	private func percentageComplete(forVerticalDrag verticalDrag: CGFloat) -> CGFloat {
		let maximumDelta = CGFloat(200)
		return CGFloat.scaleAndShift(value: verticalDrag, inRange: (min: CGFloat(0), max: maximumDelta))
	}

	/// The transition image scales down from 100% to a minimum of 68%,
	/// based on the percentage-complete of the gesture.
	func transitionImageScaleFor(percentageComplete: CGFloat) -> CGFloat {
		let minScale = CGFloat(0.68)
		let result = 1 - (1 - minScale) * percentageComplete
		return result
	}
}

extension PhotoDetailInteractiveDismissTransition: UIViewControllerAnimatedTransitioning {
	public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.3
	}

	public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		// Never called; this is always an interactive transition.
		fatalError()
	}
}

extension PhotoDetailInteractiveDismissTransition: UIViewControllerInteractiveTransitioning {
	public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
		self.transitionContext = transitionContext

		let containerView = transitionContext.containerView

		guard
			let fromView = transitionContext.view(forKey: .from),
			let toView = transitionContext.view(forKey: .to),
			let fromImageFrame = fromDelegate.imageFrame(),
			let fromImage = fromDelegate.referenceImage(),
			let fromVC = transitionContext.viewController(forKey: .from) as? PhotoDetailViewController,
			let toVC = transitionContext.viewController(forKey: .to)
		else {
			fatalError()
		}

		self.fromVC = fromVC
		self.toVC = toVC
		fromVC.transitionController = self

		fromDelegate.transitionWillStart()
		toDelegate?.transitionWillStart()
		self.fromReferenceImageViewFrame = fromImageFrame

		// We'll replace this with a better one during the transition,
		// because the collectionviews on the parent screen need a chance to re-layout.
		self.toReferenceImageViewFrame = PhotoDetailPopTransition.defaultOffscreenFrameForDismissal(
			transitionImageSize: fromImageFrame.size,
			screenHeight: fromView.bounds.height
		)

		containerView.addSubview(toView)
		containerView.addSubview(fromView)
		containerView.addSubview(transitionImageView)

		transitionImageView.image = fromImage
		transitionImageView.frame = fromImageFrame

		// NOTE: The duration and damping ratio here don't matter!
		// This animation is only programmatically adjusted in the drag state,
		// and then the duration is altered in the completion state.
		let animation = UIViewPropertyAnimator(duration: 1, dampingRatio: 1, animations: {
			if self.toDelegate == nil {
				fromView.frame.origin.x = containerView.frame.maxX
				self.transitionImageView.alpha = 0.4
			} else {
				fromView.alpha = 0
			}
		})
		self.backgroundAnimation = animation
		toVC.locketTabBarController?.setTabBar(hidden: false, animated: true, alongside: animation)
	}
}
