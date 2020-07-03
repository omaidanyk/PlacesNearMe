//
//  DataProvider.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import CoreLocation
import Foundation

typealias CoordinateBounds = (northEast: CLLocationCoordinate2D,
                              southWest: CLLocationCoordinate2D)

protocol DataProvider {
    func getStoredPlaces() -> [Place]?
    func searchPlaces(in region: CoordinateBounds, completion: @escaping([Place]?, Error?) -> Void)
}

class DataProviderImp: DataProvider {
    func getStoredPlaces() -> [Place]? {
        return nil
    }

    func searchPlaces(in region: CoordinateBounds, completion: @escaping ([Place]?, Error?) -> Void) {

    }
}
