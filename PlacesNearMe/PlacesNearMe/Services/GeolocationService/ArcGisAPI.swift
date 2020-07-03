//
//  ArcGisAPI.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import ArcGIS
import Foundation

// MARK: - ArcGisAPI

class ArcGisAPI {
    // MARK: - Static functions

    static func licenseAGS() {
        do {
            try AGSArcGISRuntimeEnvironment.setLicenseKey(Licence.arcGisLicenseKey)
        } catch {
            print("[Error: AGSArcGISRuntimeEnvironment] Error licensing app: \(error.localizedDescription)")
        }
    }

    // MARK: - Properties

    private var locatorTask: AGSLocatorTask?
    private var currentSearch: AGSCancelable?

    init() {
        self.setupLocatortask()
    }

    private func setupLocatortask() {
        guard let url = URL(string: Constants.arcGisLocatorPath) else { return }
        locatorTask = AGSLocatorTask(url: url)
    }
}

// MARK: - GeolocationService

extension ArcGisAPI: GeolocationService {
    func searchPlaces(in region: CoordinateBounds, completion: @escaping ([[String: Any]?], Error?) -> Void) {
        currentSearch?.cancel()

        let searchArea: AGSGeometry = {
            let minPoint = AGSPoint(clLocationCoordinate2D: region.northEast)
            let maxPoint = AGSPoint(clLocationCoordinate2D: region.southWest)
            return AGSEnvelope(min: minPoint, max: maxPoint)
        }()

        let searchCenter: AGSPoint = {
            let centerCoordinates = region.northEast.middleLocation(with: region.southWest)
            return AGSPoint(clLocationCoordinate2D: centerCoordinates)
        }()

        let attributeNames: [String] = [AttributeName.placeName,
                                        AttributeName.placeAddress,
                                        AttributeName.phone,
                                        AttributeName.url,
                                        AttributeName.displayX,
                                        AttributeName.displayY,
                                        AttributeName.longLabel,
                                        AttributeName.type]

        let parameters: AGSGeocodeParameters = {
            let geocodeParameters = AGSGeocodeParameters()
            geocodeParameters.maxResults = Constants.maxFetchedLocations
            geocodeParameters.resultAttributeNames.append(contentsOf: attributeNames)
            geocodeParameters.searchArea = searchArea
            geocodeParameters.preferredSearchLocation = searchCenter
            geocodeParameters.categories = [PlaceCategory.food.title]
            return geocodeParameters
        }()

        currentSearch = locatorTask?.geocode(withSearchText: "",
                                             parameters: parameters,
                                             completion: { (results, error) in
            let attributes = results?.map { $0.attributes } ?? []
            completion(attributes, error)
        })
    }
}
