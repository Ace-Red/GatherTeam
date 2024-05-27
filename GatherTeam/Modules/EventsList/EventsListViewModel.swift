//
//  EventsListViewModel.swift
//  GatherTeam
//
//

import Foundation

protocol EventsListViewModelType {
    var coordinator: EventsListCoordinator { get }
    
    func goToEvent(_ eventModel: EventModel)
}

class EventsListViewModel: EventsListViewModelType {

    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: EventsListCoordinator

    init(coordinator: EventsListCoordinator) {
        self.coordinator = coordinator
    }
    
    func goToEvent(_ eventModel: EventModel) {
        coordinator.goToEvent(eventModel)
    }
}
