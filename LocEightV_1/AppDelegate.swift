//
//  AppDelegate.swift
//  LocEightV_1
//
//  Created by Michelle Grover on 4/13/20.
//  Copyright © 2020 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    fileprivate var containerVC = ContainerViewController()
    
    var MenuContainerVC:ContainerViewController {
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive, let sceneDelegate = scene.delegate as? SceneDelegate {
                return sceneDelegate.containerVC
            }
        }
        return containerVC
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    lazy var persistantContainer:NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocEight")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print("There was an error:\(error.localizedDescription)")
            }
        }
        return container
    }()


}

