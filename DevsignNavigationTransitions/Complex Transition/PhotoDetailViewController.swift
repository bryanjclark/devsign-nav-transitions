//
//  PhotoDetailViewController.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/20/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit
import Cartography
import Photos

class PhotoDetailViewController: UIViewController {
	private let asset: PHAsset
	private let imageView = UIImageView()
	private let imageManager = PHCachingImageManager()

	init(asset: PHAsset) {
		self.asset = asset

		super.init(nibName: nil, bundle: nil)

		self.imageView.contentMode = .scaleAspectFit
		self.imageView.backgroundColor = .white
		self.imageView.accessibilityIgnoresInvertColors = true
		self.view.backgroundColor = .white

		let imageRequestOptions = PHImageRequestOptions()
		imageRequestOptions.isNetworkAccessAllowed = true
		imageRequestOptions.deliveryMode = .opportunistic
		self.imageManager.requestImage(
			for: asset,
			targetSize: self.view.bounds.size.pixelSize,
			contentMode: .aspectFit,
			options: imageRequestOptions
		) { (image, info) in
			self.imageView.image = image
		}
		
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Photo Detail"

		self.view.addSubview(self.imageView)
		constrain(self.imageView) {
			$0.edges == $0.superview!.edges
		}

		self.configureDismissGesture()
    }


	// MARK: Drag-to-dismiss

	private let dismissPanGesture = UIPanGestureRecognizer()
	public var isInteractivelyDismissing: Bool = false
	public weak var transitionController: PhotoDetailInteractiveDismissTransition? = nil

	private func configureDismissGesture() {
		self.view.addGestureRecognizer(self.dismissPanGesture)
		self.dismissPanGesture.addTarget(self, action: #selector(dismissPanGestureDidChange(_:)))
	}

	@objc private func dismissPanGestureDidChange(_ gesture: UIPanGestureRecognizer) {
		// Decide whether we're interactively-dismissing, and notify our navigation controller.
		switch gesture.state {
		case .began:
			self.isInteractivelyDismissing = true
			self.navigationController?.popViewController(animated: true)
		case .cancelled, .failed, .ended:
			self.isInteractivelyDismissing = false
		case .changed, .possible:
			break
		@unknown default:
			break
		}

		// We want to update our transition controller, too!
		self.transitionController?.didPanWith(gestureRecognizer: gesture)
	}
}

extension PhotoDetailViewController: PhotoDetailTransitionAnimatorDelegate {
	func transitionWillStart() {
		self.imageView.isHidden = true
	}

	func transitionDidEnd() {
		self.imageView.isHidden = false
	}

	func referenceImage() -> UIImage? {
		return self.imageView.image
	}

	func imageFrame() -> CGRect? {
		let rect = CGRect.makeRect(aspectRatio: imageView.image!.size, insideRect: imageView.bounds)
		return rect
	}
}
