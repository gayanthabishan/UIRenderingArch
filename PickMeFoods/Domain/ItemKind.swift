//
//  ItemKind.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import Foundation

/// Item types (product families) the registry can build
enum ItemKind: Hashable {
    case menuItem
    case promoCard
    case dessertCard
}
