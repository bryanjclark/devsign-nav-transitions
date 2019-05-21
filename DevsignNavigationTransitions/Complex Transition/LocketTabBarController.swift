//
//  LocketTabBarController.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/20/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

/** A custom tab-bar-controller that:
- requires that its viewControllers be LocketNavigationControllers,
- keeps its tab bar hidden appropriately
- animates its tab bar in/out nicely
**/
public class LocketTabBarController: UITabBarController {
	public var isTabBarHidden: Bool = false

	public var shouldTabBarBeSuppressed: Bool {
		guard
			let currentLocketNavigationController = self.selectedViewController as? LocketNavigationController
			else {
				fatalError()
		}
		return  currentLocketNavigationController.shouldTabBarBeHidden
	}

	public override var viewControllers: [UIViewController]? {
		willSet {
			// Assert that all child view controllers are a LocketNavigationController
			newValue?.forEach {
				assert($0.isKind(of: LocketNavigationController.self))
			}
		}
	}
}

// via https://www.iamsim.me/hiding-the-uitabbar-of-a-uitabbarcontroller/
extension LocketTabBarController {
	/**
	Show or hide the tab bar.
	*/
	func setTabBar(
		hidden: Bool,
		animated: Bool = true,
		alongside animator: UIViewPropertyAnimator? = nil
		) {
		// We don't show the tab bar if the navigation state of the current tab disallows it.
		if !hidden, self.shouldTabBarBeSuppressed {
			return
		}

		guard isTabBarOffscreen != hidden else { return }
		self.isTabBarHidden = hidden

		let offsetY = hidden ? tabBar.frame.height : -tabBar.frame.height
		let endFrame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
		let vc = selectedViewController
		var newInsets: UIEdgeInsets? = vc?.additionalSafeAreaInsets
		let originalInsets = newInsets
		newInsets?.bottom -= offsetY

		/// Helper method for updating child view controller's safe area insets.
		func set(childViewController cvc: UIViewController?, additionalSafeArea: UIEdgeInsets) {
			cvc?.additionalSafeAreaInsets = additionalSafeArea
			cvc?.view.setNeedsLayout()
		}

		// Update safe area insets for the current view controller before the animation takes place when hiding the bar.
		if
			hidden,
			let insets = newInsets
		{
			set(childViewController: vc, additionalSafeArea: insets)
		}

		guard animated else {
			tabBar.frame = endFrame
			tabBar.isHidden = self.isTabBarHidden
			return
		}

		/// If the tab bar was previously hidden, we need to un-hide it.
		if self.tabBar.isHidden, !hidden {
			self.tabBar.isHidden = false
		}

		// Perform animation with coordination if one is given. Update safe area insets _after_ the animation is complete,
		// if we're showing the tab bar.
		weak var tabBarRef = self.tabBar
		if let animator = animator {
			animator.addAnimations {
				tabBarRef?.frame = endFrame
			}
			animator.addCompletion { (position) in
				let insets = (position == .end) ? newInsets : originalInsets
				if
					!hidden,
					let insets = insets
				{
					set(childViewController: vc, additionalSafeArea: insets)
				}
				if (position == .end) {
					tabBarRef?.isHidden = hidden
				}
			}
		} else {
			UIView.animate(withDuration: 0.3, animations: {
				tabBarRef?.frame = endFrame
			}) { didFinish in
				if !hidden, didFinish, let insets = newInsets {
					set(childViewController: vc, additionalSafeArea: insets)
				}
				tabBarRef?.isHidden = hidden
			}
		}
	}

	/// `true` if the tab bar is currently hidden.
	fileprivate var isTabBarOffscreen: Bool {
		return !tabBar.frame.intersects(view.frame)
	}
}

public extension UIViewController {
	var locketNavigationController: LocketNavigationController? {
		return self.navigationController as? LocketNavigationController
	}

	var locketTabBarController: LocketTabBarController? {
		return self.tabBarController as? LocketTabBarController
	}
}

