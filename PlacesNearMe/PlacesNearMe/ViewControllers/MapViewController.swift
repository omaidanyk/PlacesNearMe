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
    private var firstLoad: Bool = true
    private var locationManager = CLLocationManager()
    private var selectedPlace: String?

    // MARK: - Setup

    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = Constants.locationTrackingDistanceFilter
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    private func setupMapStyle() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let styleName = isDarkMode ? Constants.mapDarkStyleName : Constants.mapLightStyleName

        do {
            if let styleURL = Bundle.main.url(forResource: styleName,
                                              withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find \(styleName).json")
            }
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
        setupMapStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedPlaceID = selectedPlace {
            loadStoredPlace(selectedPlaceID)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            setupMapStyle()
        }
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

    private func loadStoredPlace(_ placeID: String) {
        guard let storedPlaces = dataProvider.getStoredPlaces() else { return }
        guard let place = storedPlaces.first(where: { $0.longLabel == placeID }) else { return }
        display(storedPlaces)

        moveTo(place.location, zoomLevel: .detail)
    }
    // MARK: - Camera move

    private func moveTo(_ position: CLLocationCoordinate2D, zoomLevel: CameraZoomLevel = .default) {
        let camera = GMSCameraPosition.camera(withTarget: position,
                                              zoom: zoomLevel.rawValue)
        mapView.animate(to: camera)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedPlaceID = selectedPlace else { return }
        guard let presentable = segue.destination as? PlacePresentable else { return }

        presentable.showSelectedPlace(selectedPlaceID)
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

// MARK: - MapPresentable

extension MapViewController: PlacePresentable {
    func showSelectedPlace(_ placeId: String) {
        selectedPlace = placeId
    }
}
