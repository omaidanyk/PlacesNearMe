//
//  MapViewController.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import GoogleMaps
import UIKit

class MapViewController: UIViewController {
    // MARK: - IBOutlets

    @IBOutlet private weak var mapView: GMSMapView!

    // MARK: - Properties

    private let dataProvider: DataProvider = DataProviderImp()
    private var locationManager = CLLocationManager()
    private var firstLoad: Bool = true
    private var selectedPlace: String?

    // MARK: - Setup

    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = Constants.locationTrackingDistanceFilter
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    private func setupMapStyleWithoutPOI() {
        // disable default points of interest
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: Constants.mapStyleWithoutPOI)
        } catch {
            print("Failed to change map style: \(error.localizedDescription)")
        }
    }

    private func setupLocationPermissions() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            setupUserLocationMapOverlay()
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }

    private func setupUserLocationMapOverlay() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
        setupLocationPermissions()
        setupMapStyleWithoutPOI()
    }

    // MARK: - Places workaround

    private func loadVisiblePlaces() {
        let storedPlaces = dataProvider.getStoredPlaces()
        let places = visiblePlaces(from: storedPlaces)

        // note: Here we will search for new places on every camera move/zoom, except first load.
        // It makes updates more smooth
        // Remove <!firstLoad> check if you don't want to request new places
        //   while at least one stored place is visible
        if places.isEmpty || !firstLoad {
            searchForNewPlaces()
        } else {
            display(places)
        }
    }

    private func searchForNewPlaces() {
        let visibleBouds = GMSCoordinateBounds(region: mapView.projection.visibleRegion())
        let simpleBounds: CoordinateBounds = (visibleBouds.northEast, visibleBouds.southWest)
        dataProvider.searchPlaces(in: simpleBounds) { [weak self] (places, error) in
            self?.handleFoundPlaces(places, error: error)
        }
    }

    private func handleFoundPlaces(_ places: [Place]?, error: Error?) {
        guard let places = places else {
            print("Failed to search places from api:\n\(error?.localizedDescription ?? "")")
            return
        }
        display(places)
    }

    private func visiblePlaces(from places: [Place]?) -> [Place] {
        guard let places = places else { return [] }

        let visible: [Place] = places.filter({
            return mapView.projection.contains($0.location)
        })

        return visible
    }

    private func display(_ places: [Place]) {
        // remove current markers
        mapView.clear()

        // create new markers
        for place in places {
            let marker = GMSMarker(position: place.location)
            marker.title = place.name
            marker.snippet = place.type
            marker.userData = place.longLabel
            marker.map = mapView

            // restore selection if any
            if let selected = selectedPlace, place.longLabel == selected {
                mapView.selectedMarker = marker
            }
        }
    }
    // MARK: - Camera move

    private func moveTo(_ position: CLLocationCoordinate2D) {
        let camera = GMSCameraPosition.camera(withTarget: position,
                                              zoom: Constants.defaultCameraZoomLevel)
        mapView.animate(to: camera)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {

        guard status == .authorizedWhenInUse || status == .authorizedAlways else { return }
        setupUserLocationMapOverlay()
        locationManager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if firstLoad {
            moveTo(location.coordinate)
            firstLoad = false
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if !firstLoad {
            loadVisiblePlaces()
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // avoid scrolling to the marker on marker tap
        mapView.selectedMarker = marker
        selectedPlace = marker.userData as? String

        return true
    }

    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.selectedMarker = nil
        selectedPlace = nil
    }
}
