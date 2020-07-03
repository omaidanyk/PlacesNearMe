//
//  CoreDataStack.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import CoreData
import Foundation

// MARK: - CoreDataStack

class CoreDataStack {
    // MARK: - Properties

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.databaseName)
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                //TODO: handle errors
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var viewContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    // MARK: - Core Data Saving support

    func save(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            fatalError("Error: \(error)\nCould not save Core Data context.")
        }
    }

    // MARK: - Handling entities

    private func createPlace(from data: [String: Any], in context: NSManagedObjectContext) -> Place? {
        let entity = NSEntityDescription.insertNewObject(forEntityName: Place.entityName,
                                                         into: context)
        guard let place = entity as? Place else {
            print("Error: Failed to create a new place!")
            return nil
        }
        place.update(with: data)

        return place
    }
}

// MARK: - Storage

extension CoreDataStack: Storage {
    func loadStoredPlaces() -> [Place]? {
        let request: NSFetchRequest<Place> = Place.fetchRequest()

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to load data from CoreData")
            return nil
        }
    }

    func removeAllPlaces() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Place")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: viewContext)
        } catch let error as NSError {
            fatalError("Failed to delete existed places: \(error)")
        }
    }

    func savePlaces(_ placesData: [[String: Any]?]) -> [Place] {
        var places: [Place] = []

        for placeData in placesData {
            guard let data = placeData else { continue }
            guard let place = createPlace(from: data, in: viewContext) else { continue }

            places.append(place)
        }

        save(viewContext)
        return places
    }
}
