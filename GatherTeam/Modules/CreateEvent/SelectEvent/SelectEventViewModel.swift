//
//  SelectEventViewModel.swift
//  GatherTeam
//
//  Created by Nikita on 10.01.2024.
//

import Foundation
import Combine

protocol SelectEventViewModelType {
    var coordinator: SelectEventCoordinator { get }
    
    var filterModel: Published<FilterModel?>.Publisher { get }
    
    func goToFilters()
}

class SelectEventViewModel: SelectEventViewModelType {
    @Published private var filters: FilterModel?
    
    var filterModel: Published<FilterModel?>.Publisher { $filters }

    // MARK: - Inputs


    // MARK: - Outputs
    var coordinator: SelectEventCoordinator

    init(coordinator: SelectEventCoordinator) {
        self.coordinator = coordinator
    }
    
    func goToFilters() {
        coordinator.goToFilters { [weak self] gettedFilters in
            guard let self else { return }
            
            filters = gettedFilters
        }
    }
}
