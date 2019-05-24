//
//  CGSize+Blixt.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/21/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

public extension CGFloat {
	/// Returns the value, scaled-and-shifted to the targetRange.
	/// If no target range is provided, we assume the unit range (0, 1)
	static func scaleAndShift(
		value: CGFloat,
		inRange: (min: CGFloat, max: CGFloat),
		toRange: (min: CGFloat, max: CGFloat) = (min: 0.0, max: 1.0)
		) -> CGFloat {
		assert(inRange.max > inRange.min)
		assert(toRange.max > toRange.min)

		if value < inRange.min {
			return toRange.min
		} else if value > inRange.max {
			return toRange.max
		} else {
			let ratio = (value - inRange.min) / (inRange.max - inRange.min)
			return toRange.min + ratio * (toRange.max - toRange.min)
		}
	}
}

public extension CGSize {
	/// Scales up a point-size CGSize into its pixel representation.
	var pixelSize: CGSize {
		let scale = UIScreen.main.scale
		return CGSize(width: self.width * scale, height: self.height * scale)
	}
}

public extension CGRect {
	/// Kinda like AVFoundation.AVMakeRect, but handles tall-skinny aspect ratios differently.
	/// Returns a rectangle of the same aspect ratio, but scaleAspectFit inside the other rectangle.
	static func makeRect(aspectRatio: CGSize, insideRect rect: CGRect) -> CGRect {
		let viewRatio = rect.width / rect.height
		let imageRatio = aspectRatio.width / aspectRatio.height
		let touchesHorizontalSides = (imageRatio > viewRatio)

		let result: CGRect
		if touchesHorizontalSides {
			let height = rect.width / imageRatio
			let yPoint = rect.minY + (rect.height - height) / 2
			result = CGRect(x: 0, y: yPoint, width: rect.width, height: height)
		} else {
			let width = rect.height * imageRatio
			let xPoint = rect.minX + (rect.width - width) / 2
			result = CGRect(x: xPoint, y: 0, width: width, height: rect.height)
		}
		return result
	}
}
