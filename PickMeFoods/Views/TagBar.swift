//
//  TagBar.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

struct TagBar: View {
    let sections: [SectionSchema]
    @Binding var active: SectionKind?
    let onTap: (SectionKind) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sections) { section in
                    let isActive = active == section.id

                    Button {
                        onTap(section.id)
                    } label: {
                        Text(section.headerTitle)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            // Fill with Capsule
                            .background(
                                Capsule()
                                    .fill(isActive ? Color.black : Color.clear)
                            )
                            // Stroke with Capsule
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        isActive ? Color.black : Color.black.opacity(0.2),
                                        lineWidth: 1
                                    )
                            )
                            // Ensure hit area and anti‑aliasing are on the capsule shape
                            .contentShape(Capsule())
                            .foregroundColor(isActive ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("tag_\(section.id.rawValue)")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        // Keep the bar’s background on the container, not per-chip
        .background(Color(.systemBackground))
    }
}
