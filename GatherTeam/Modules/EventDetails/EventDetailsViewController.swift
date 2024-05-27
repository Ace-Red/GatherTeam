//
//  EventDetailsViewController.swift
//  GatherTeam
//
//  Created by Nikita on 22.02.2024.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import MapKit

class EventDetailsViewController: UIViewController {
    var viewModel: EventDetailsViewModelType!
    var isAdmin: Bool!
    
    private var ref: DatabaseReference!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EventDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventDetailsTableViewCell", for: indexPath) as! EventDetailsTableViewCell
        cell.eventImageView.image = viewModel.eventModel.type?.placeholder
        cell.eventName.text = viewModel.eventModel.name ?? ""
        cell.eventDescription.text = viewModel.eventModel.description ?? ""
        
        let restaurantLocation = CLLocationCoordinate2D(latitude: viewModel.eventModel.latitude ?? 0, longitude: viewModel.eventModel.longitude ?? 0)
        cell.mapView.setCenter(restaurantLocation, animated: true)
        
        // Set the delegate of the map view
        cell.mapView.delegate = self
        cell.mapView.isScrollEnabled = false
        cell.datePicker.date = viewModel.eventModel.eventDate
        cell.datePicker.isUserInteractionEnabled = false
        cell.leaveButtonOutlet.setTitle(isAdmin ? "Delete event" : "Leave event", for: .normal)
        cell.pressedOnMapCompletion = { [weak self] in
            guard
                let self,
                let latitude = viewModel.eventModel.latitude,
                let longitude = viewModel.eventModel.longitude
            else { return }
            
            if let url = URL(string: "comgooglemaps://?q=\(latitude),\(longitude)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        cell.pressedPlayersCompletion = { [weak self] in
            guard let self else { return }
            
            viewModel.goToPlayersList()
        }
        
        cell.pressedLeaveCompletion = { [weak self] in
            guard let self else { return }
            
            removeEventFromSelectedEvents()
        }

        // Create an annotation for a specific location
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: viewModel.eventModel.latitude ?? 0, longitude: viewModel.eventModel.longitude ?? 0)
        annotation.title = viewModel.eventModel.name ?? ""
        
        // Add the annotation to the map view
        cell.mapView.addAnnotation(annotation)
        cell.mapView.layer.borderWidth = 1
        cell.mapView.layer.borderColor = UIColor(rgb: 0x121111).cgColor
        
        // Optionally, you can set the region to focus on
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        cell.mapView.setRegion(region, animated: true)
        
        return cell
    }
    
    func removeEventFromSelectedEvents() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if isAdmin {
            ref.child("events").child(viewModel.eventModel.id).removeValue()
        } else {
            ref.child("users").child(uid).child("data").child("selectedEvents").getData { [weak self] error, snapshot in
                guard let self, var selectedEvents = snapshot?.value as? [String] else {
                    return
                }
                
                selectedEvents.removeAll(where: { $0 == self.viewModel.eventModel.id })
                ref.child("users").child(uid).child("data").child("selectedEvents").setValue(selectedEvents)
                updateEvent()
            }
        }
    }
    
    func updateEvent() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ref.child("events").child(viewModel.eventModel.id).child("users").getData { [weak self] error, snapshot in
            guard let self else {
                return
            }

            var selectedUsers = snapshot?.value as? [String] ?? []
            
            selectedUsers.removeAll(where: { $0 == uid })
            ref.child("events").child(viewModel.eventModel.id).child("users").setValue(selectedUsers)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension EventDetailsViewController: UITableViewDelegate, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView.canShowCallout = true
        return pinView
    }
}
