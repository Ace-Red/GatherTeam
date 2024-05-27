//
//  EventTableViewCell.swift
//  GatherTeam
//
//  Created by Nikita on 22.02.2024.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventImageCell: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var usersCountLabel: UILabel!
    @IBOutlet weak var bcView: UIView!
    @IBOutlet weak var usersCountView: UIView!
    @IBOutlet weak var starsView: UIView!
    @IBOutlet weak var starsCountLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var timerView: UIView!
    
    var timer: Timer?
    
    func configure(with eventDate: Date) {
        // Calculate time difference
        let currentDate = Date()
        let timeRemaining = eventDate.timeIntervalSince(currentDate)
        
        // Update countdown label
        updateCountdownLabel(with: timeRemaining)
        
        // Start timer to update countdown label periodically
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let timeRemaining = eventDate.timeIntervalSince(Date())
            self.updateCountdownLabel(with: timeRemaining)
        }
    }
    
    private func updateCountdownLabel(with timeRemaining: TimeInterval) {
        let hours = Int(timeRemaining) / 3600
        let minutes = (Int(timeRemaining) % 3600) / 60
        let seconds = Int(timeRemaining) % 60
        
        countdownLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timer?.invalidate()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bcView.layer.borderWidth = 1
        bcView.layer.borderColor = UIColor(rgb: 0x121111).withAlphaComponent(0.3).cgColor
        
        usersCountView.layer.borderWidth = 1
        usersCountView.layer.borderColor = UIColor(rgb: 0x121111).withAlphaComponent(0.3).cgColor
        
        starsView.layer.borderWidth = 1
        starsView.layer.borderColor = UIColor(rgb: 0x121111).withAlphaComponent(0.3).cgColor
        
        timerView.layer.borderWidth = 1
        timerView.layer.borderColor = UIColor(rgb: 0x121111).withAlphaComponent(0.3).cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
