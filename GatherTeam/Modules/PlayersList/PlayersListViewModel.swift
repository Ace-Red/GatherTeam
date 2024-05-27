//
//  PlayersListViewModel.swift
//  GatherTeam
//
//

import Foundation

protocol PlayersListViewModelType {
    var coordinator: PlayersListCoordinator { get }
    
    var eventModel: EventModel { get set }
}

class PlayersListViewModel: PlayersListViewModelType {

    var eventModel: EventModel
    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: PlayersListCoordinator

    init(coordinator: PlayersListCoordinator, eventModel: EventModel) {
        self.coordinator = coordinator
        self.eventModel = eventModel
    }
}


