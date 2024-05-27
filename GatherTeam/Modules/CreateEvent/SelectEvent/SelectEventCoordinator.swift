//
//  SelectEventCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 10.01.2024.
//


import UIKit

class SelectEventCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "SelectEventViewController") as! SelectEventViewController
        viewController.viewModel = SelectEventViewModel(coordinator: self)
        self.navigationController.pushViewController(viewController, animated: true)
    }
    
    func goToFilters(_ completion: @escaping ((FilterModel) -> Void)) {
        coordinate(to: FiltersCoordinator(navigationController: navigationController, completion: completion))
    }
}

