//
//  ProfileViewModel.swift
//  GatherTeam
//
//  Created by Nikita on 07.12.2023.
//

import Foundation

enum Settings: Int, CaseIterable {
    case createEvent = 0, myCreatedEvents
    
    var title: String {
        switch self {
        case .createEvent:
            return "Create event"
        case .myCreatedEvents:
            return "My created events"
        }
    }
    
    var icon: String {
        switch self {
        case .createEvent:
            return "add-event"
        case .myCreatedEvents:
            return "ic_no_events"
        }
    }
}

protocol ProfileViewModelType {
    var coordinator: ProfileCoordinator { get }
    
    func goToEnterEventName()
    func goToEventsList()
}

class ProfileViewModel: ProfileViewModelType {

    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: ProfileCoordinator

    init(coordinator: ProfileCoordinator) {
        self.coordinator = coordinator
    }
    
    func goToEnterEventName() {
        self.coordinator.goToEnterEventName()
    }
    
    func goToEventsList() {
        self.coordinator.goToEventsList()
    }
}
