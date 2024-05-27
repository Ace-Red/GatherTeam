//
//  PlayersListCoordinator.swift
//  GatherTeam
//
//

import UIKit

class PlayersListCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!
    private var eventModel: EventModel!

    init(navigationController: UINavigationController, eventModel: EventModel) {
        self.navigationController = navigationController
        self.eventModel = eventModel
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "PlayersListViewController") as! PlayersListViewController
        viewController.viewModel = PlayersListViewModel(coordinator: self, eventModel: eventModel)
        self.navigationController.pushViewController(viewController, animated: true)
    }
}
