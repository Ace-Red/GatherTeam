//
//  CreateEventViewModel.swift
//  GatherTeam
//
//  Created by Nikita on 27.12.2023.
//

import Foundation

protocol CreateEventViewModelType {
    var coordinator: CreateEventCoordinator { get }
    
    var eventModel: EventModel { get set }
}

class CreateEventViewModel: CreateEventViewModelType {

    var eventModel: EventModel
    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: CreateEventCoordinator

    init(coordinator: CreateEventCoordinator, eventModel: EventModel) {
        self.coordinator = coordinator
        self.eventModel = eventModel
    }
}
