//
//  AppDelegate.swift
//  DevsignNavigationTransitions
//
//  Created by Bryan Clark on 5/7/19.
//  Copyright © 2019 Bryan Clark. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.window?.rootViewController = RootViewController()
		self.window?.makeKeyAndVisible()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {}
	func applicationDidEnterBackground(_ application: UIApplication) {}
	func applicationWillEnterForeground(_ application: UIApplication) {}
	func applicationDidBecomeActive(_ application: UIApplication) {}
	func applicationWillTerminate(_ application: UIApplication) {}
}

