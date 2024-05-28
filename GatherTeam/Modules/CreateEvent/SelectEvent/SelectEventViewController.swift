//
//  SelectEventViewController.swift
//  GatherTeam
//
//  Created by Nikita on 10.01.2024.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import Combine
import MapKit
import CoreLocation

class SelectEventViewController: UIViewController, UITextViewDelegate {
    
    var viewModel: SelectEventViewModelType!
    @IBOutlet weak var collectionView: UICollectionView!
    private var events: [EventModel] = []
    private var ref: DatabaseReference!
    private var cancallables: Set<AnyCancellable> = .init()
    private var currentEvent: EventModel?
    private var currentEventIndex = 0
    @IBOutlet weak var placeholderView: UIView!
    private let locationManager = LocationManager()
    private var filt: FilterModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.height * 0.6)
        
        collectionView.collectionViewLayout = layout
        
        ref = Database.database().reference()
        getEvents(with: nil)
        setupSubscriptions()
    }
    
    func scrollToNextCell() {
        guard 
            let collectionView = collectionView,
            currentEventIndex < events.count
        else {
            placeholderView.isHidden = false
            return
        }
        currentEvent = events[currentEventIndex]
        
        if let currentIndexPath = collectionView.indexPathsForVisibleItems.first {
            let nextIndexPath = IndexPath(item: currentIndexPath.item + 1, section: currentIndexPath.section)
            
            if nextIndexPath.item < collectionView.numberOfItems(inSection: nextIndexPath.section) {
                collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func getEvents(with filterModel: FilterModel?) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        guard let filterModel else {
            ref.child("events").getData { [weak self] error,snapshot  in
                guard let self else { return }
                
                processEvents(with: snapshot)
            }
            return
        }
        
        ref.child("events").queryOrdered(byChild: "type").queryEqual(toValue: filterModel.eventType.rawValue).observe(.value) { [weak self] snapshot  in
            guard let self else { return }
            
            placeholderView.isHidden = !(snapshot.value as? [String: [String:Any]] ?? [:]).isEmpty
            
            if (snapshot.value as? [String: [String:Any]] ?? [:]).isEmpty {
                return
            }
            
            processEvents(with: snapshot)
        }
    }
    
    func processEvents(with snapshot: DataSnapshot?) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        var events: [EventModel] = []
        
        for event in snapshot?.value as? [String: [String:Any]] ?? [:] {
            if let usersIds = event.value["users"] as? [String], usersIds.contains(userId) { continue }
            
            events.append(EventModel(
                id: event.key,
                name: event.value["name"] as? String,
                description: event.value["description"] as? String,
                type: EventTypes(rawValue: event.value["type"] as? Int ?? 0),
                latitude: CLLocationDegrees(event.value["latitude"] as? Int ?? 0),
                longitude: CLLocationDegrees(event.value["longitude"] as? Int ?? 0),
                usersIds: event.value["users"] as? [String] ?? [],
                eventDate: Int.generateDateFromTimestamp(with: event.value["eventDate"] as? Int ?? 0),
                distanceToEventFromPhone: haversineDistance(
                    lat1: event.value["latitude"] as? Double ?? 0,
                    lon1: event.value["longitude"] as? Double ?? 0,
                    lat2: locationManager.latitude,
                    lon2: locationManager.longitude
                )
            ))
        }
        self.events = events
        self.currentEvent = events.first
        self.currentEventIndex = 0
        self.collectionView.reloadData()
        self.getUsersRatings()
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
                        let avRating = userRates.reduce(0, +) / Double(event.usersIds.count)
                        if let minimumPlayersRate = filt?.playersRate, avRating < Double(minimumPlayersRate) {
                            self.events.removeAll(where: { $0.id == event.id })
                        } else {
                            updateEventWithRating(with: avRating, for: event.id)//БО НЕ ПОПАДАЄ СЮДИ
                        }
                        
                        checkEvents()
                    }
                }
            }
            
            if let minimumPlayersRate = filt?.playersRate, minimumPlayersRate > 0, event.usersIds.count == 0 {
                self.events.removeAll(where: { $0.id == event.id })
                checkEvents()
            }
        }
    }
    
    func updateEventWithRating(with rating: Double, for eventId: String) {
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            events[index].averageUsersRating = rating
        }
        
        self.events = self.events.sorted(by: { event1, event2 in
            let weightedSum1 = ((event1.averageUsersRating / 5) * 0.6) + ((1 - (self.getDistanceInMeters(with: event1.distanceToEventFromPhone)/40000000)) * 0.4)
            let weightedSum2 = ((event2.averageUsersRating / 5) * 0.6) + ((1 - (self.getDistanceInMeters(with: event2.distanceToEventFromPhone)/40000000)) * 0.4)
            return weightedSum1 > weightedSum2
        })
        
        self.currentEvent = self.events.first
        self.collectionView.reloadData()
    }
    
    func checkEvents() {
        if events.isEmpty {
            self.currentEvent = nil
            self.placeholderView.isHidden = false
            self.collectionView.reloadData()
        }
    }
    
    func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let lat1Rad = lat1 * Double.pi / 180
        let lon1Rad = lon1 * Double.pi / 180
        let lat2Rad = lat2 * Double.pi / 180
        let lon2Rad = lon2 * Double.pi / 180
        
        let dLat = lat2Rad - lat1Rad
        let dLon = lon2Rad - lon1Rad
        
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        // Radius of the Earth in kilometers
        let radius = 6371.0
        
        let distance = radius * c
        return distance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func goToFilters(_ sender: UIButton) {
        viewModel.goToFilters()
    }
    
    @IBAction func approvePressed(_ sender: UIButton) {
        guard let currentEvent, let uid = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users").child(uid).child("data").child("selectedEvents").getData { [weak self] error, snapshot in
            guard let self, var selectedEvents = snapshot?.value as? [String] else {
                self?.ref.child("users").child(uid).child("data").child("selectedEvents").setValue([currentEvent.id])
                self?.updateEvent()
                return
            }
            
            guard !selectedEvents.contains(currentEvent.id) else { return }

            selectedEvents.append(currentEvent.id)
            ref.child("users").child(uid).child("data").child("selectedEvents").setValue(selectedEvents)
            updateEvent()
        }
    }
    
    @IBAction func declinePressed(_ sender: UIButton) {
        currentEventIndex += 1
        scrollToNextCell()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupSubscriptions() {
        viewModel
            .filterModel
            .compactMap({ $0 })
            .sink(receiveCompletion: { completion in
                print(completion)
            }, receiveValue: { [weak self] filters in
                self?.filt = filters
                self?.getEvents(with: filters)
            })
            .store(in: &cancallables)
    }
    
    private func generateDistanceString(with distanceToEventFromPhone: Double) -> String {
        let km = Int(distanceToEventFromPhone)
        let meters = Int(distanceToEventFromPhone.truncatingRemainder(dividingBy: 1) * 1000)
        
        if km > 0 {
            return "📍Away from you: \(km) km \(meters) m"
        } else {
            return "📍Away from you: \(meters) m"
        }
    }
    
    private func getDistanceInMeters(with distanceToEventFromPhone: Double) -> Double {
        let km = Int(distanceToEventFromPhone)
        let meters = Int(distanceToEventFromPhone.truncatingRemainder(dividingBy: 1) * 1000)
        
        if km > 0 {
            return Double((km * 1000) + meters)//   "📍Away from you: \(km) km \(meters) m"
        } else {
            return Double(meters) //"📍Away from you: \(meters) m"
        }
    }
}

extension SelectEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return events.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectEventCollectionViewCell", for: indexPath) as! SelectEventCollectionViewCell
        cell.eventName.text = events[indexPath.item].name ?? ""
        cell.descriptionLabel.text = events[indexPath.item].description ?? ""
        cell.eventImageView.layer.masksToBounds = true
        cell.eventImageView.image = events[indexPath.item].type?.placeholder
        cell.datePicker.date = events[indexPath.item].eventDate
        cell.datePicker.isUserInteractionEnabled = false
        cell.ditanseToEvent.text = generateDistanceString(with: events[indexPath.item].distanceToEventFromPhone)
        cell.starCountLabel.text = String(format: "%.2f", events[indexPath.item].averageUsersRating)
        cell.usersCountLabel.text = "\(events[indexPath.item].usersIds.count)"
        return cell
    }
}

extension SelectEventViewController: UICollectionViewDelegate { }

private extension SelectEventViewController {
    func updateEvent() {
        guard let currentEvent, let uid = Auth.auth().currentUser?.uid else { return }
        
        ref.child("events").child(currentEvent.id).child("users").getData { [weak self] error, snapshot in
            guard let self else {
                self?.ref.child("events").child(currentEvent.id).child("users").setValue([uid])
                return
            }

            var selectedUsers = snapshot?.value as? [String] ?? []
            
            selectedUsers.append(uid)
            ref.child("events").child(currentEvent.id).child("users").setValue(selectedUsers)
            
            currentEventIndex += 1
            scrollToNextCell()
        }
    }
}
