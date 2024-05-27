//
//  SelectEventTypeCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 24.12.2023.
//

import UIKit

class SelectEventTypeCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!
    private var eventModel: EventModel!

    init(navigationController: UINavigationController, eventModel: EventModel) {
        self.navigationController = navigationController
        self.eventModel = eventModel
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "SelectEventTypeViewController") as! SelectEventTypeViewController
        viewController.viewModel = SelectEventTypeViewModel(coordinator: self)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func goToSelectDates(_ type: EventTypes) {
        eventModel.type = type
        coordinate(to: CreateEventCoordinator(navigationController: navigationController, eventModel: eventModel))
    }
}
