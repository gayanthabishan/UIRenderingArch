//
//  SectionHeaderOffsetKey.swift
//  PickMeFoods
//
//  Created by Bishanm on 2025-08-11.
//

import SwiftUI

/// Collect section header Y offsets in the scroll space.
/// Maps SectionKind, offset to determine which section is at the top.
struct SectionHeaderOffsetKey: PreferenceKey {
    static var defaultValue: [SectionKind: CGFloat] = [:]
    static func reduce(value: inout [SectionKind: CGFloat],
                       nextValue: () -> [SectionKind: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}
