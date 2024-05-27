//
//  EnterEventNameViewModel.swift
//  GatherTeam
//
//  Created by Nikita on 24.12.2023.
//

import Foundation

protocol EnterEventNameViewModelType {
    var coordinator: EnterEventNameCoordinator { get }
    
    func goToSelectEnentType(_ name: String, _ description: String)
}

class EnterEventNameViewModel: EnterEventNameViewModelType {

    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: EnterEventNameCoordinator

    init(coordinator: EnterEventNameCoordinator) {
        self.coordinator = coordinator
    }
    
    func goToSelectEnentType(_ name: String, _ description: String) {
        let model = EventModel(id: UUID().uuidString, name: name, description: description, usersIds: [])
        self.coordinator.goToSelectEnentType(with: model)
    }
}
