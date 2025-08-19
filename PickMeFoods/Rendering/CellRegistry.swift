//
//  CellRegistry.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

/// Maps an ItemKind to a strongly-typed builder closure.
/// Super lightweight for the POC.
struct CellRegistry {
    static var builders: [ItemKind: (AnyHashable) -> AnyView] = [:]

    static func register<Model: Hashable, Content: View>(
        kind: ItemKind,
        builder: @escaping (Model) -> Content
    ) {
        builders[kind] = { anyModel in
            guard let model = anyModel as? Model else { return AnyView(EmptyView()) }
            return AnyView(builder(model))
        }
    }

    static func build(_ item: ItemSchema) -> AnyView {
        builders[item.kind]?(item.model) ?? AnyView(EmptyView())
    }
}
