//
//  PromoCard.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

struct PromoCard: View {
    let model: PromoModel
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.2))
                .frame(height: 120)
                .overlay(Text("Image").foregroundColor(.blue))
            Text(model.title)
                .font(.subheadline)
                .lineLimit(2)
            Spacer()
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
}
