//
//  AppDelegate.swift
//  GatherTeam
//
//

import UIKit
import FirebaseCore
import FirebaseCore
import FirebaseAuth
import StoreKit
import GoogleSignIn
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainCoordinator: MainCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.overrideUserInterfaceStyle = .light
        mainCoordinator = MainCoordinator(window: window!)
        
        FirebaseApp.configure()
        
        mainCoordinator?.start()
        
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 32
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
