//
//  ScrollCoordinator.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import Foundation

final class ScrollCoordinator: ObservableObject {
    /// Which section is currently active (for highlighting the tag bar)
    @Published var activeSection: SectionKind? = nil
    /// Whether the outlet header is visible (controls showing the sticky tag bar)
    @Published var isOutletHeaderVisible: Bool = true
}
