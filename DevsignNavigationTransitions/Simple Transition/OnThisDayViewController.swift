//
//  OnThisDayViewController.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/7/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

class OnThisDayViewController: UIViewController {

	init() {
		super.init(nibName: nil, bundle: nil)
		self.title = "Simple"
		self.tabBarItem.image = UIImage(named: "Simple")
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .white

		self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Present Modal", style: .plain, target: self, action: #selector(presentModal))
    }

	@objc private func presentModal() {
		let modalCard = ModalCardViewController()
		self.present(modalCard, animated: true, completion: nil)
	}
}
