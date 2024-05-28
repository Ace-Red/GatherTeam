//
//  MyEventsViewController.swift
//  GatherTeam
//
//  Created by Nikita on 07.12.2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Combine
import MapKit

class MyEventsViewController: UIViewController {
    @IBOutlet weak var searchOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholderView: UIView!
    
    private var events: [EventModel] = []
    private var ref: DatabaseReference = Database.database().reference()
    
    var viewModel: MyEventsViewModelType!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupEventsSubscription()
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        viewModel.goToSelectEvent()
    }
    
    @IBAction func addEventPressed(_ sender: UIButton) {
        viewModel.goToSelectEvent()
    }
    
    func setupEventsSubscription() {
        guard let uid = Auth.auth().currentUser?.uid else {
            events.removeAll()
            tableView.reloadData()
            return
        }
        
        ref.child("users").child(uid).child("data").child("selectedEvents").observe(.value) { [weak self] snapshot in
            guard let self, let selectedEvents = snapshot.value as? [String] else {
                self?.events.removeAll()
                self?.placeholderView.isHidden = !(self?.events.isEmpty ?? false)
                self?.tableView.reloadData()
                return
            }
            
            for removedEventsId in Set(events.map { $0.id }).subtracting(selectedEvents) {
                events.removeAll(where: { $0.id == removedEventsId })
                placeholderView.isHidden = !events.isEmpty
                tableView.reloadData()
            }
            
            for eventId in selectedEvents {
                guard !events.contains(where: { $0.id == eventId }) else { continue }
                
                ref.child("events").child(eventId).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    guard
                        let self,
                        let snapshotDict = snapshot.value as? [String: Any],
                        snapshot.exists()
                    else { return }
                    
                    guard !events.contains(where: { $0.id == eventId }) else { return }
                    
                    events.append(EventModel(
                        id: eventId,
                        name: snapshotDict["name"] as? String,
                        description: snapshotDict["description"] as? String,
                        type: EventTypes(rawValue: snapshotDict["type"] as? Int ?? 0),
                        latitude: CLLocationDegrees(snapshotDict["latitude"] as? Double ?? 0),
                        longitude: CLLocationDegrees(snapshotDict["longitude"] as? Double ?? 0),
                        usersIds: snapshotDict["users"] as? [String] ?? [],
                        repeatedEvent: snapshotDict["repeatedEvent"] as? Bool ?? false,
                        eventDate: Int.generateDateFromTimestamp(with: snapshotDict["eventDate"] as? Int ?? 0),
                        averageUsersRating: 0
                    ))
                    
                    placeholderView.isHidden = !events.isEmpty
                    tableView.reloadData()
                    getUsersRatings()
                }) { error in
                    print("Error retrieving event: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getUsersRatings() {
        for event in events {
            var userRates: [Double] = []
            for (index, userId) in event.usersIds.enumerated() {
                ref.child("users").child(userId).child("data").child("globalRating").getData { [weak self] error, snapshot in
                    guard let self else {
                        return
                    }
                    let userRating = snapshot?.value as? [Int] ?? [0]
                    
                    userRates.append(Double(userRating.reduce(0, +)/userRating.count))
                    
                    if index == event.usersIds.count - 1 {
                        updateEventWithRating(with: userRates.reduce(0, +) / Double(event.usersIds.count), for: event.id)
                    }
                }
            }
        }
    }
    
    func updateEventWithRating(with rating: Double, for eventId: String) {
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            events[index].averageUsersRating = rating
        }
        tableView.reloadData()
    }
}

extension MyEventsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { events.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventTableViewCell", for: indexPath) as! EventTableViewCell
        cell.eventNameLabel.text = events[indexPath.item].name ?? ""
        cell.descriptionLabel.text = events[indexPath.item].description ?? ""
        cell.starsCountLabel.text = String(format: "%.2f", events[indexPath.item].averageUsersRating)
        cell.eventImageCell.image = events[indexPath.item].type?.placeholder
        cell.usersCountLabel.text = "\(events[indexPath.item].usersIds.count)"
        cell.configure(with: events[indexPath.item].eventDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 176 }
}

extension MyEventsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.goToEvent(events[indexPath.item])
    }
}
