//
//  EventDetailsCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 22.02.2024.
//

import UIKit

class EventDetailsCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!
    private var eventModel: EventModel!
    private var isAdmin: Bool!

    init(navigationController: UINavigationController, eventModel: EventModel, isAdmin: Bool) {
        self.navigationController = navigationController
        self.eventModel = eventModel
        self.isAdmin = isAdmin
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "EventDetailsViewController") as! EventDetailsViewController
        viewController.viewModel = EventDetailsViewModel(coordinator: self, eventModel: eventModel)
        viewController.isAdmin = isAdmin
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func goToPlayersList(_ eventModel: EventModel) {
        coordinate(to: PlayersListCoordinator(navigationController: navigationController, eventModel: eventModel))
    }
}
