//
//  PlaceListViewController.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import UIKit

class PlaceListViewController: UITableViewController {
    // MARK: - Constants
    private enum UIConstants {
        static let titleSize: CGFloat = 18
        static let subTitleSize: CGFloat = 14

        static let cellID: String = "placeCell"
    }

    // MARK: - Properties

    private var selectedPlaceId: String?
    private var places = [Place]()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let placeID = selectedPlaceId else { return }
        select(placeID: placeID, animated: animated)
    }

    // MARK: - setup

    private func setupDataSource() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        places = appDelegate.storage.loadStoredPlaces() ?? []
    }

    // MARK: - private methods

    private func select(placeID: String, animated: Bool) {
        guard let row = places.firstIndex(where: { $0.longLabel == placeID }) else { return }
        let indexPath = IndexPath(row: row, section: 0)
        tableView.selectRow(at: indexPath, animated: animated, scrollPosition: .none)
    }

    private func attributedTitle(for place: Place) -> NSAttributedString {
        let result = NSMutableAttributedString()

        guard let name = place.name else { return result }
        let nameAttrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UIConstants.titleSize)]
        let attributedName = NSAttributedString(string: name, attributes: nameAttrs)
        result.append(attributedName)

        guard let type = place.type else { return result }
        let typeAttrs = [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: UIConstants.subTitleSize)]
        let attributedType = NSMutableAttributedString(string: "\n\(type)", attributes: typeAttrs)
        result.append(attributedType)

        return result
    }

    private func showSelectedPlaceOnMap() {
        guard let map = navigationController?.viewControllers.first as? PlacePresentable else { return }
        guard let placeID = selectedPlaceId else { return }

        map.showSelectedPlace(placeID)
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - Table view data source

extension PlaceListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIConstants.cellID, for: indexPath)

        let place = places[indexPath.row]

        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.attributedText = attributedTitle(for: place)
        cell.detailTextLabel?.text = place.address

        cell.accessoryView = UIImageView(image: UIImage.mapPinAndEllipse)
        cell.accessoryView?.tintColor = .darkGray

        return cell
    }
}

// MARK: - Table view delegate

extension PlaceListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        selectedPlaceId = place.longLabel
        showSelectedPlaceOnMap()
    }
}

// MARK: - PlaceListPresentable

extension PlaceListViewController: PlacePresentable {
    func showSelectedPlace(_ placeId: String) {
        selectedPlaceId = placeId
    }
}
