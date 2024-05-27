//
//  PlayerTableViewCell.swift
//  GatherTeam
//
//

import UIKit

class PlayerTableViewCell: UITableViewCell {
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet var starsLabel: [UIButton]!
    
    var starPressedHandler: ((Int) -> Void)?
    
    @IBAction func starPressed(_ sender: UIButton) {
        starPressedHandler?(sender.tag)
    }
}
