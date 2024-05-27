//
//  EventDetailsTableViewCell.swift
//  GatherTeam
//
//  Created by Nikita on 23.03.2024.
//

import UIKit
import MapKit

class EventDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var leaveButtonOutlet: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var pressedOnMapCompletion: (() -> Void)?
    var pressedPlayersCompletion: (() -> Void)?
    var pressedLeaveCompletion: (() -> Void)?

    @IBAction func playersPressed(_ sender: UIButton) {
        pressedPlayersCompletion?()
    }
    
    @IBAction func pressedOnMap(_ sender: UIButton) {
        pressedOnMapCompletion?()
    }
    
    @IBAction func leaveButtonPressed(_ sender: UIButton) {
        pressedLeaveCompletion?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leaveButtonOutlet.layer.cornerRadius = 16
        leaveButtonOutlet.layer.borderWidth = 1
        leaveButtonOutlet.layer.borderColor = UIColor.red.cgColor
        
        // Ensure content starts from top ignoring safe area
        let topInset = contentView.safeAreaInsets.top
        let currentFrame = contentView.frame
        contentView.frame = CGRect(x: currentFrame.origin.x,
                                   y: currentFrame.origin.y - topInset,
                                   width: currentFrame.width,
                                   height: currentFrame.height + topInset)
    }
}
