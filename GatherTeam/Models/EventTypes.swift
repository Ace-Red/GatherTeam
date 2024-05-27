//
//  EventTypes.swift
//  GatherTeam
//
//  Created by Nikita on 26.11.2023.
//

import Foundation
import UIKit

enum EventTypes: Int, CaseIterable {
    case football = 0, hokey, volayball, bigTenis, smallTenis, monopoly, poker
    
    var title: String {
        switch self {
        case .football:
            return "Football"
        case .hokey:
            return "Hokey"
        case .volayball:
            return "Volayball"
        case .bigTenis:
            return "Big tennis"
        case .smallTenis:
            return "Small tennis"
        case .monopoly:
            return "Monopoly"
        case .poker:
            return "Poker"
        }
    }
    
    var typeImage: String {
        switch self {
        case .football:
            return "⚽️"
        case .hokey:
            return "🏒"
        case .volayball:
            return "🏐"
        case .bigTenis:
            return "🎾"
        case .smallTenis:
            return "🏓"
        case .monopoly:
            return "🌆"
        case .poker:
            return "🃏"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .football:
            return UIImage(named: "ic_football")
        case .hokey:
            return UIImage(named: "ic_hokey")
        case .volayball:
            return UIImage(named: "ic_volleyball")
        case .bigTenis:
            return UIImage(named: "ic_tenis")
        case .smallTenis:
            return UIImage(named: "ic_pingPong")
        case .monopoly:
            return UIImage(named: "ic_monopoly")
        case .poker:
            return UIImage(named: "ic_poker")
        }
    }
    
    var placeholder: UIImage? {
        switch self {
        case .football:
            return UIImage(named: "football_placeholder")
        case .volayball:
            return UIImage(named: "vollayball_placeholder")
        case .bigTenis:
            return UIImage(named: "tenis_placeholder")
        case .smallTenis:
            return UIImage(named: "pingpong_placeholder")
        case .poker:
            return UIImage(named: "poker_placeholder")
        case .monopoly:
            return UIImage(named: "monopoly_placeholder")
        case .hokey:
            return UIImage(named: "hokey_placeholder")
        }
    }
}
