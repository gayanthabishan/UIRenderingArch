//
//  DessertCard.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

struct DessertCard: View {
    let model: DessertModel
    let addToCart: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.pink.opacity(0.2))
                .frame(height: 180)
                .overlay(Text("Image").foregroundColor(.pink))
            Text(model.title)
                .font(.subheadline)
                .lineLimit(2)
            Spacer()
            Button("Add to cart") { addToCart() }
                .buttonStyle(.bordered)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}
