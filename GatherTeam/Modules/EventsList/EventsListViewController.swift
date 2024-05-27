//
//  EventsListViewController.swift
//  GatherTeam
//
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import MapKit
import Combine

class EventsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: EventsListViewModelType!
    
    private var ref: DatabaseReference!
    private var events: [EventModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        getData()
    }
    
    func getData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        ref.child("events").queryOrdered(byChild: "author").queryEqual(toValue: userId).observe(.value) { [weak self] snapshot  in
            guard let self else { return }
            
            processEvents(with: snapshot)
        }
    }
    
    func processEvents(with snapshot: DataSnapshot?) {
        var events: [EventModel] = []
        
        for event in snapshot?.value as? [String: [String:Any]] ?? [:] {
            events.append(EventModel(
                id: event.key,
                name: event.value["name"] as? String,
                description: event.value["description"] as? String,
                type: EventTypes(rawValue: event.value["type"] as? Int ?? 0),
                latitude: CLLocationDegrees(event.value["latitude"] as? Double ?? 0),
                longitude: CLLocationDegrees(event.value["longitude"] as? Double ?? 0),
                usersIds: event.value["users"] as? [String] ?? [],
                eventDate: Int.generateDateFromTimestamp(with: event.value["eventDate"] as? Int ?? 0),
                distanceToEventFromPhone: 0
            ))
        }
        self.events = events
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension EventsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { events.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmallEventTableViewCell", for: indexPath) as! SmallEventTableViewCell
        cell.eventNameLabel.text = events[indexPath.item].name ?? ""
        cell.eventImageView.image = events[indexPath.item].type?.image
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 86 }
}

extension EventsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.goToEvent(events[indexPath.item])
    }
}
