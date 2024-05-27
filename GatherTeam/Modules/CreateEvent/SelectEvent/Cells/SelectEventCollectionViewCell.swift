//
//  EventCollectionViewCell.swift
//  GatherTeam
//
//  Created by Nikita on 10.01.2024.
//

import UIKit

class SelectEventCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ditanseToEvent: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var usersCountLabel: UILabel!
    @IBOutlet weak var usersCountView: UIView!
    @IBOutlet weak var starsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usersCountView.layer.borderWidth = 1
        usersCountView.layer.borderColor = UIColor(rgb: 0x121111).withAlphaComponent(0.3).cgColor
        
        starsView.layer.borderWidth = 1
        starsView.layer.borderColor = UIColor(rgb: 0x121111).withAlphaComponent(0.3).cgColor
    }
}
