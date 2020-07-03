//
//  Place+CoreDataClass.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//
//

import CoreData
import CoreLocation
import Foundation

// MARK: - Place

@objc(Place)
public class Place: NSManagedObject {
    static let entityName: String = "Place"

    func update(with attributes: [String: Any]) {
        name = attributes[AttributeName.placeName] as? String
        address = attributes[AttributeName.placeAddress] as? String
        latitude = attributes[AttributeName.displayY] as? Double ?? 0
        longitude = attributes[AttributeName.displayX] as? Double ?? 0
        phone = attributes[AttributeName.phone] as? String
        url = attributes[AttributeName.url] as? String
        longLabel = attributes[AttributeName.longLabel] as? String
        type = attributes[AttributeName.type] as? String
    }
}

// MARK: - Place + location

extension Place {
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
