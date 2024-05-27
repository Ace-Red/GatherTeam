//
//  FiltersViewModel.swift
//  GatherTeam
//
//  Created by Nikita on 15.01.2024.
//

import Foundation

protocol FiltersViewModelType {
    var coordinator: FiltersCoordinator { get }
    
    func applyFilters(with model: FilterModel)
}

class FiltersViewModel: FiltersViewModelType {
    var completion: (FilterModel) -> Void
    // MARK: - Inputs


    // MARK: - Outputs

    var coordinator: FiltersCoordinator

    init(coordinator: FiltersCoordinator, completion: @escaping (FilterModel) -> Void) {
        self.coordinator = coordinator
        self.completion = completion
    }
    
    func applyFilters(with model: FilterModel) {
        completion(model)
    }
}
