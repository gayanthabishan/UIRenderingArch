//
//  OutletViewModel.swift
//  PickMeFoods
//  Self-contained demo with fake fetch and fake data.
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

class OutletPOCViewModel: ObservableObject {
    @Published var sections: [SectionSchema] = []
    @Published var cartCount: Int = 0
    
    func load() {
        // Simulate async fetch
        sections = []
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 500_000_000)
            self.sections = Self.makeFakeSections()
        }
    }
    
    func addToCart() {
        cartCount += 1
        print(cartCount)
    }
    
    private static func makeFakeSections() -> [SectionSchema] {
        let lunchItems: [ItemSchema] = [
            ItemSchema(kind: .menuItem, model: MenuItemModel(name: "Chicken Fried Rice", price: 1200, rating: 4.5)),
            ItemSchema(kind: .menuItem, model: MenuItemModel(name: "Kottu Roti", price: 950, rating: 4.3)),
            ItemSchema(kind: .menuItem, model: MenuItemModel(name: "Veggie Wrap", price: 800, rating: 4.0)),
        ]
        
        let dinnerItems: [ItemSchema] = [
            ItemSchema(kind: .menuItem, model: MenuItemModel(name: "Grilled Chicken", price: 1600, rating: 4.6)),
            ItemSchema(kind: .menuItem, model: MenuItemModel(name: "Maggie Noodles", price: 1450, rating: 4.4)),
            ItemSchema(kind: .menuItem, model: MenuItemModel(name: "Beef Steak", price: 2500, rating: 4.7)),
        ]
        
        let promoItems: [ItemSchema] = (1...8).map { i in
            ItemSchema(kind: .promoCard, model: PromoModel(title: "Promo #\(i)"))
        }
        
        let dessertItems: [ItemSchema] = (1...8).map { i in
            ItemSchema(kind: .dessertCard, model: DessertModel(title: "Dessert #\(i)"))
        }
        
        return [
            SectionSchema(
                id: .lunch,
                headerTitle: SectionKind.lunch.rawValue,
                layout: .list,
                isSticky: true,
                items: lunchItems
            ),
            SectionSchema(
                id: .dinner,
                headerTitle: SectionKind.dinner.rawValue,
                layout: .list,
                isSticky: true,
                items: dinnerItems
            ),
            SectionSchema(
                id: .promos,
                headerTitle: SectionKind.promos.rawValue,
                layout: .horizontalCard(size: CGSize(width: 150, height: 200)),
                isSticky: true,
                items: promoItems
            ),
            SectionSchema(
                id: .desserts,
                headerTitle: SectionKind.desserts.rawValue,
                layout: .horizontalCard(size: CGSize(width: 150, height: 300)),
                isSticky: true,
                items: dessertItems
            )
        ]
    }
}
