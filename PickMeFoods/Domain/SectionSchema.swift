//
//  SectionSchema.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import Foundation

/// The screen is a composition of sections; each section contains items
struct SectionSchema: Identifiable, Hashable {
    let id: SectionKind
    let headerTitle: String
    let layout: LayoutStyle
    let isSticky: Bool
    let items: [ItemSchema]
}

// Compare & hash by `id` (sections are uniquely identified by their kind)
// Avoids hashing large item arrays.
extension SectionSchema {
    static func == (lhs: SectionSchema, rhs: SectionSchema) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
