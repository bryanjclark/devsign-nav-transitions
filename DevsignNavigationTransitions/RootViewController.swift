//
//  RootViewController.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/7/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
	private let tabController = UITabBarController()
	private let firstTab = PhotoGridViewController()
	private let secondTab = OnThisDayViewController()

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.tabController.willMove(toParent: self)
		self.addChild(tabController)
		self.view.addSubview(tabController.view)
		self.tabController.didMove(toParent: self)
		self.tabController.view.frame = self.view.bounds
		self.tabController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]

		let firstNavC = UINavigationController(rootViewController: firstTab)
		self.tabController.addChild(firstNavC)

		let secondNavC = UINavigationController(rootViewController: secondTab)
		self.tabController.addChild(secondNavC)
    }
}
