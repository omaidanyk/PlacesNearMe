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

    private var locationManager = CLLocationManager()
    private var firstLoad: Bool = true

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
