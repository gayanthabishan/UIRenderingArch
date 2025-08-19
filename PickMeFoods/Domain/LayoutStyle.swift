//
//  LayoutStyle.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import CoreGraphics

/// Layout strategies a section can use
enum LayoutStyle: Equatable {
    case list
    case horizontalCard(size: CGSize)
}
