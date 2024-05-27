//
//  FiltersCoordinator.swift
//  GatherTeam
//
//  Created by Nikita on 15.01.2024.
//

import UIKit

class FiltersCoordinator: Coordinator<Void> {
    private weak var navigationController: UINavigationController!
    var completion: (FilterModel) -> Void

    init(navigationController: UINavigationController, completion: @escaping ((FilterModel) -> Void)) {
        self.navigationController = navigationController
        self.completion = completion
    }

    override func start() {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let viewController = st.instantiateViewController(withIdentifier: "FiltersViewController") as! FiltersViewController
        viewController.viewModel = FiltersViewModel(coordinator: self, completion: completion)
        self.navigationController.pushViewController(viewController, animated: true)
    }
}
