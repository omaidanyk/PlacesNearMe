//
//  GeolocationService.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import Foundation

protocol GeolocationService {
    func searchPlaces(in region: CoordinateBounds,
                      completion: @escaping([[String: Any]?], Error?) -> Void)
}
