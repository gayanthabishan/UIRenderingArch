//
//  OutletHeaderView.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

struct OutletHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 160)
                .overlay(Text("Outlet Image").foregroundColor(.gray))
            HStack(spacing: 8) {
                Circle().fill(Color.green).frame(width: 8, height: 8)
                Text("Open now")
                    .font(.subheadline).foregroundColor(.green)
            }
            Text("Demo Outlet")
                .font(.title2).bold()
            Text("123, Flower Road, Colombo")
                .font(.subheadline).foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}
