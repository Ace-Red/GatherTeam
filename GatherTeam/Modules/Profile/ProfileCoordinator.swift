//
//  ProfileCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 07.12.2023.
//

import UIKit

class ProfileCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        viewController.viewModel = ProfileViewModel(coordinator: self)
        presentedViewController = viewController
    }
    
    func goToEnterEventName() {
        coordinate(to: EnterEventNameCoordinator(navigationController: navigationController))
    }
    
    func goToEventsList() {
        coordinate(to: EventsListCoordinator(navigationController: navigationController))
    }
}
