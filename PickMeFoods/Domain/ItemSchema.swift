//
//  ItemSchema.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import Foundation

/// An item is typed (via ItemKind) and carries its model as type-erased Hashable
struct ItemSchema: Identifiable, Hashable {
    let id = UUID()
    let kind: ItemKind
    let model: AnyHashable
}
