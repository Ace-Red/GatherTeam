//
//  MyEventsCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 07.12.2023.
//

import UIKit

class MyEventsCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController?.navigationBar.isHidden = true
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "MyEventsViewController") as! MyEventsViewController
        viewController.viewModel = MyEventsViewModel(coordinator: self)
        viewController.navigationController?.navigationBar.isHidden = true
        presentedViewController = viewController
    }
    
    func goToSelectEvent() {
        coordinate(to: SelectEventCoordinator(navigationController: navigationController))
    }
    
    func goToEvent(_ eventModel: EventModel) {
        coordinate(to: EventDetailsCoordinator(navigationController: navigationController, eventModel: eventModel, isAdmin: false))
    }
}
