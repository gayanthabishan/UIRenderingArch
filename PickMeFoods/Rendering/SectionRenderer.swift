//
//  SectionRenderer.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

struct SectionRenderer: View {
    let section: SectionSchema
    let addToCart: () -> Void
    
    var body: some View {
        switch section.layout {
        case .list:
            VStack(spacing: 12) {
                ForEach(section.items) { item in
                    switch item.kind {
                    case .menuItem:
                        if let model = item.model as? MenuItemModel {
                            MenuItemCell(model: model, addToCart: addToCart)
                        }
                    default:
                        CellRegistry.build(item)
                    }
                }
            }
            .padding(.horizontal)
        case .horizontalCard(let size):
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(section.items) { item in
                        switch item.kind {
                        case .promoCard:
                            if let model = item.model as? PromoModel {
                                PromoCard(model: model)
                                    .frame(width: size.width, height: size.height)
                            }
                        case .dessertCard:
                            if let model = item.model as? DessertModel {
                                DessertCard(model: model, addToCart: addToCart)
                                    .frame(width: size.width, height: size.height)
                            }
                        default:
                            CellRegistry.build(item)
                                .frame(width: size.width, height: size.height)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
