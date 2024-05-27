//
//  EventModel.swift
//  GatherTeam
//
//  Created by Nikita on 24.12.2023.
//

import MapKit

struct EventModel: Hashable {
    var id: String
    var name: String?
    var description: String?
    var type: EventTypes?
    var playersAmount: Int?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var usersIds: [String]
    var repeatedEvent: Bool = false
    var eventDate = Date()
    var averageUsersRating: Double = 0
    
    
    // MARK: - Local variables
    var distanceToEventFromPhone: Double = 0
}

struct RatingModel {
    var parentId: String
    var childId: String
    var rating: Int
}
