//
//  DataProviderImp.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import UIKit

class DataProviderImp {
    private var storage: Storage? = StorageImp()
    private var geoService: GeolocationService? = GeolocationServiceImp()
}

// MARK: - DataProvider

extension DataProviderImp: DataProvider {
    func getStoredPlaces() -> [Place]? {
        return storage?.loadStoredPlaces()
    }

    func searchPlaces(in region: CoordinateBounds,
                      completion: @escaping ([Place]?, Error?) -> Void) {
        geoService?.searchPlaces(in: region, completion: { [weak self] (results, error) in
            guard error == nil, results.count > 0 else {
                print(error?.localizedDescription ?? "Fail to load places from AGS")
                completion(nil, error)
                return
            }

            self?.storage?.removeAllPlaces()
            let places = self?.storage?.savePlaces(results)

            completion(places, error)
        })
    }
}
