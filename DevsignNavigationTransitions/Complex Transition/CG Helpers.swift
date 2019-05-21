//
//  CGSize+Blixt.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/21/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

public extension CGSize {
	/// Scales up a point-size CGSize into its pixel representation.
	var pixelSize: CGSize {
		let scale = UIScreen.main.scale
		return CGSize(width: self.width * scale, height: self.height * scale)
	}
}

public extension CGRect {
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
