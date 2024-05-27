//
//  Coordinator.swift
//  GatherTeam
//
//

import UIKit

class Coordinator<ResultType> {
    var presentedViewController: UIViewController!

    func coordinate<T>(to coordinator: Coordinator<T>) {
        coordinator.start()
    }

    func start() {
        fatalError()
    }
}
