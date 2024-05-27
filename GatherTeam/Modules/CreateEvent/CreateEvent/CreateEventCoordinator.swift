//
//  CreateEventCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 27.12.2023.
//

import UIKit

class CreateEventCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!
    private var eventModel: EventModel!

    init(navigationController: UINavigationController, eventModel: EventModel) {
        self.navigationController = navigationController
        self.eventModel = eventModel
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
        viewController.viewModel = CreateEventViewModel(coordinator: self, eventModel: eventModel)
        self.navigationController.pushViewController(viewController, animated: true)
    }
}
