//
//  EventDetailsViewModel.swift
//  GatherTeam
//
//  Created by Nikita on 22.02.2024.
//

import Foundation

protocol EventDetailsViewModelType {
    var coordinator: EventDetailsCoordinator { get }
    
    var eventModel: EventModel { get set }
    func goToPlayersList()
}

class EventDetailsViewModel: EventDetailsViewModelType {

    var eventModel: EventModel
    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: EventDetailsCoordinator

    init(coordinator: EventDetailsCoordinator, eventModel: EventModel) {
        self.coordinator = coordinator
        self.eventModel = eventModel
    }
    
    func goToPlayersList() {
        coordinator.goToPlayersList(eventModel)
    }
}
