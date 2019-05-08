//
//  PhotoGridViewController.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/7/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit
import Cartography

class PhotoGridViewController: UIViewController {

	init() {
		super.init(nibName: nil, bundle: nil)
		self.title = "Complex"
		self.tabBarItem.image = UIImage(named: "Complex")
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .white

		let todoLabel = UILabel()
		todoLabel.numberOfLines = 0
		todoLabel.lineBreakMode = .byWordWrapping
		todoLabel.text = "This tab is for our more-complex navigation transition — we'll cover that in a future post!"
		todoLabel.font = UIFont.italicSystemFont(ofSize: 20)
		todoLabel.textAlignment = .center
		todoLabel.textColor = UIColor.darkGray
		self.view.addSubview(todoLabel)
		constrain(todoLabel) {
			$0.center == $0.superview!.center
			$0.leading == $0.superview!.safeAreaLayoutGuide.leading + 16
			$0.trailing == $0.superview!.safeAreaLayoutGuide.trailing - 16
		}
    }
}
