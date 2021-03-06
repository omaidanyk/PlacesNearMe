//
//  Constants.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import Foundation

struct Constants {

    // these constants can be moved to some settings
    static let locationTrackingDistanceFilter: Double = 50
    static let maxFetchedLocations: Int = 20

    static let databaseName: String = "PlacesNearMe"
    static let arcGisLocatorPath = "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
    static let mapLightStyleName = "DayStyle"
    static let mapDarkStyleName = "NightStyle"
}
