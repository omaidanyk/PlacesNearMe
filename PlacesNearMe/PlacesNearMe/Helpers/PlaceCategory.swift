//
//  PlaceCategory.swift
//  PlacesNearMe
//
//  Created by Oleksii Maidanyk on 03.07.2020.
//  Copyright © 2020 omaid. All rights reserved.
//

import Foundation

enum PlaceCategory {
    case food
    case restaurants //unused for now
    case coffeeShops //unused for now

    var title: String {
        switch self {
        case .food:
            return "Food"
        case .restaurants:
            return "Restaurants"
        case .coffeeShops:
            return "Coffee shop"
        // don't use default to make sure that all cases will be covered
        }
    }
}
