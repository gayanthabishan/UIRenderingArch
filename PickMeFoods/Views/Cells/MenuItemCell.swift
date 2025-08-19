//
//  MenuItemCell.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

struct MenuItemCell: View {
    let model: MenuItemModel
    let addToCart: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            // Placeholder image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 56, height: 56)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.headline)
                Text(String(format: "Rs %.0f", model.price))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill").font(.caption)
                    Text(String(format: "%.1f", model.rating)).font(.caption)
                }.foregroundColor(.yellow)
            }
            Spacer()
            Button("Add") { addToCart() }
                .buttonStyle(.borderedProminent)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white)
        .cornerRadius(10)
    }
}
