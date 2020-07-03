//
//  Storage.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import Foundation

protocol Storage {
    func loadStoredPlaces() -> [Place]?
    func removeAllPlaces()
    func savePlaces(_ placesData: [[String: Any]?]) -> [Place]
}

class StorageImp: Storage {
    func loadStoredPlaces() -> [Place]? {
        return nil
    }

    func removeAllPlaces() { }
    func savePlaces(_ placesData: [[String: Any]?]) -> [Place] {
        return []
    }
}
