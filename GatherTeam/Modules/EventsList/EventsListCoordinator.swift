//
//  EventsListCoordinator.swift
//  GatherTeam
//
//

import UIKit

class EventsListCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "EventsListViewController") as! EventsListViewController
        viewController.viewModel = EventsListViewModel(coordinator: self)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func goToEvent(_ eventModel: EventModel) {
        coordinate(to: EventDetailsCoordinator(navigationController: navigationController, eventModel: eventModel, isAdmin: true))
    }
}
