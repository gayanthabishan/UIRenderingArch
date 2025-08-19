//
//  SectionKind.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import Foundation

/// Sections we want to render
enum SectionKind: String, CaseIterable, Hashable, Identifiable {
    case lunch = "Lunch"
    case dinner = "Dinner"
    case promos = "Promotions"
    case desserts = "Desserts"

    var id: String { rawValue }
}
