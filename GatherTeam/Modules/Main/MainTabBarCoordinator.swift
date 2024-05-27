//
//  MainTabBarCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 07.12.2023.
//

import UIKit

class MainCoordinator: Coordinator<Void> {
    private let window: UIWindow!
    private var navigationController: UINavigationController!

    private var myEventsCoordinator: MyEventsCoordinator!
    private var profileCoordinator: ProfileCoordinator!

    init(window: UIWindow) {
        self.window = window
    }

    override func start() {

        let tabBarController = MainTabBarController()

        self.navigationController = UINavigationController(rootViewController: tabBarController)

        presentedViewController = navigationController

        setupTabs(tabBarController: tabBarController)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    private func setupTabs(tabBarController: UITabBarController) {
        myEventsCoordinator = MyEventsCoordinator(navigationController: navigationController)
        myEventsCoordinator.start()
        let myEventsVC = myEventsCoordinator.presentedViewController ?? UIViewController()
        myEventsVC.tabBarItem = UITabBarItem(title: "My events", image: UIImage(named: "ic_list"), selectedImage: UIImage(named: "ic_list"))

        profileCoordinator = ProfileCoordinator(navigationController: navigationController)
        profileCoordinator.start()
        let profileVC = profileCoordinator.presentedViewController ?? UIViewController()
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "ic_profile"), selectedImage: UIImage(named: "ic_profile_selected"))

        tabBarController.setViewControllers([myEventsVC, profileVC], animated: false)
        tabBarController.selectedIndex = 0
    }
}
