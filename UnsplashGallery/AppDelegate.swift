//
//  AppDelegate.swift
//  UnsplashGallery
//
//  Created by Georgij Emelyanov on 17/09/2019.
//  Copyright © 2019 Georgij Emelyanov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let nc: UINavigationController = .init(rootViewController: ViewController())
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
        return true
    }
}

