//
//  EnterEventNameCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 24.12.2023.
//

import UIKit

class EnterEventNameCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "EnterEventNameViewController") as! EnterEventNameViewController
        viewController.viewModel = EnterEventNameViewModel(coordinator: self)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func goToSelectEnentType(with model: EventModel) {
        coordinate(to: SelectEventTypeCoordinator(navigationController: navigationController, eventModel: model))
    }
}
