//
//  MyEventsViewModel.swift
//  GatherTeam
//
//  Created by Nikita on 07.12.2023.
//

import Foundation

protocol MyEventsViewModelType {
    var coordinator: MyEventsCoordinator { get }
    
    func goToSelectEvent()
    func goToEvent(_ eventModel: EventModel)
}

class MyEventsViewModel: MyEventsViewModelType {

    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: MyEventsCoordinator

    init(coordinator: MyEventsCoordinator) {
        self.coordinator = coordinator
    }
    
    func goToSelectEvent() {
        coordinator.goToSelectEvent()
    }
    
    func goToEvent(_ eventModel: EventModel) {
        coordinator.goToEvent(eventModel)
    }
}
