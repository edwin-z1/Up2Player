//
//  AppDelegate.swift
//  Up2Player
//
//  Created by blurryssky on 2019/1/21.
//  Copyright © 2019 blurryssky. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FileManager.up2p.createDirectorys()
        return true
    }

}

