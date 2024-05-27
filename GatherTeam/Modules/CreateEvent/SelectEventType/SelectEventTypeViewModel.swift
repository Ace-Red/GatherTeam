//
//  SelectEventTypeViewModel.swift
//  GatherTeam
//
//  Created by Nikita on 24.12.2023.
//

import Foundation

protocol SelectEventTypeViewModelType {
    var coordinator: SelectEventTypeCoordinator { get }
    
    func goToSelectDates(_ type: EventTypes)
}

class SelectEventTypeViewModel: SelectEventTypeViewModelType {

    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: SelectEventTypeCoordinator

    init(coordinator: SelectEventTypeCoordinator) {
        self.coordinator = coordinator
    }
    
    func goToSelectDates(_ type: EventTypes) {
        coordinator.goToSelectDates(type)
    }
}
