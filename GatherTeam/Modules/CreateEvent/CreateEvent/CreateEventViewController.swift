//
//  CreateEventViewController.swift
//  GatherTeam
//
//  Created by Nikita on 27.12.2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class CreateEventViewController: UIViewController {
    
    @IBOutlet private weak var enterNeededPlayersLabel: UILabel!
    @IBOutlet private weak var stepperOutlet: UIStepper!
    @IBOutlet private weak var repeatedEventToggle: UISwitch!
    @IBOutlet private weak var eventDatePicker: UIDatePicker!
    @IBOutlet var starsLabel: [UIButton]!
    
    private var minimumStars = 1
    
    private var ref: DatabaseReference!
    var viewModel: CreateEventViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        stepperOutlet.minimumValue = 1
        stepperOutlet.maximumValue = 12
        stepperOutlet.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func stepperChanged(_ stepper: UIStepper) {
        enterNeededPlayersLabel.text = "Enter needed players amount: \(Int(stepper.value))"
        let feedback = UISelectionFeedbackGenerator()
        feedback.selectionChanged()
        
        expensiveAsyncDataUpdate(with: Int(stepper.value))
    }
    
    func expensiveAsyncDataUpdate(with value: Int) {
        
    }
    
    @IBAction func starPressed(_ sender: UIButton) {
        minimumStars = sender.tag
        
        for index in 0..<starsLabel.count {
            starsLabel[index].tintColor = index < sender.tag ? .systemYellow : .systemGray
        }
    }
    
    @IBAction func addLocationPressed(_ sender: UIButton) {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: "SelectLocationViewController") as! SelectLocationViewController
        vc.selectedLocationCompletion = { [weak self] location in
            guard let self, let location else { return }
            
            viewModel.eventModel.latitude = location.latitude
            viewModel.eventModel.longitude = location.longitude
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func createEventPressed(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard
            let latitude = viewModel.eventModel.latitude,
            let longitude = viewModel.eventModel.longitude
        else {
            let alert = UIAlertController(title: "You could not create event", message: "You need to select location.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let event = [
            "id": UUID().uuidString,
            "author": uid,
            "name": viewModel.eventModel.name ?? "",
            "description": viewModel.eventModel.description ?? "",
            "playersAmount": Int(stepperOutlet.value),
            "type": viewModel.eventModel.type?.rawValue ?? 0,
            "longitude": longitude,
            "latitude": latitude,
            "repeatedEvent": repeatedEventToggle.isOn,
            "eventDate": Int(eventDatePicker.date.timeIntervalSince1970),
            "minimumStars": minimumStars
        ] as [String : Any]
        
        ref.child("events").childByAutoId().updateChildValues(event)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
