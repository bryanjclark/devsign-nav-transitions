//
//  PhotoGridViewController.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/7/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

class PhotoGridViewController: UIViewController {

	init() {
		super.init(nibName: nil, bundle: nil)
		self.title = "Grid"
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		self.view.backgroundColor = .white
    }
}
