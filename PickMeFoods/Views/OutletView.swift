//
//  OutletView.swift
//  PickMeFoods
//
//  Created by Bishan Meddegoda on 2025-08-11.
//

import SwiftUI

struct OutletView: View {
    @StateObject private var vm = OutletPOCViewModel()
    @StateObject private var scroll = ScrollCoordinator()

    private let TAG_BAR_HEIGHT: CGFloat = 36
    // Hysteresis thresholds (in points) to avoid flapping near the top edge
    private let showThreshold: CGFloat = 0      // show TagBar when first header crosses
    private let hideThreshold: CGFloat = 12     // hide TagBar only after header moves well down

    // Dependency injection point
    init(vm: OutletPOCViewModel = OutletPOCViewModel(),
         scroll: ScrollCoordinator = ScrollCoordinator()) {
        _vm = StateObject(wrappedValue: vm)
        _scroll = StateObject(wrappedValue: scroll)
    }
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                    // Outlet header
                    OutletHeaderView()
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)

                    // Sections with sticky headers
                    ForEach(vm.sections) { section in
                        Section(
                            header:
                                HStack {
                                    Text(section.headerTitle)
                                        .font(.title3).bold()
                                        .padding(.horizontal)
                                        .padding(.top, 8)
                                        .padding(.bottom, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            // Publish each header's position in the same coord space
                                            GeometryReader { gp in
                                                Color.clear.preference(
                                                    key: SectionHeaderOffsetKey.self,
                                                    value: [section.id: gp.frame(in: .named("scroll")).minY]
                                                )
                                            }
                                        )
                                        .background(Color(.systemBackground)) // opaque for clean pinning
                                }
                                .id(section.id)
                        ) {
                            SectionRenderer(section: section, addToCart: { vm.addToCart() })
                                .padding(.bottom, 10)
                        }
                        
                        // add overscroll only for whatever the last section
                        // so last section can be reached from the tag clicks
                        if section.id == vm.sections.last?.id {
                            Color.clear.frame(height: 400)
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))

                // Active section + TagBar visibility from FIRST header, with hysteresis
                .onPreferenceChange(SectionHeaderOffsetKey.self) { map in
                    // Which section is at/near the top (unchanged)
                    if let current = map
                        .sorted(by: { $0.value < $1.value })
                        .first(where: { $0.value >= -2 && $0.value < 60 })?
                        .key
                    {
                        scroll.activeSection = current
                    }

                    // Drive TagBar visibility from the FIRST section header position
                    guard let firstId = vm.sections.first?.id, let firstY = map[firstId] else { return }

                    // Hysteresis: flip only when we cross the threshold in the intended direction
                    if scroll.isOutletHeaderVisible {
                        // Currently header is visible; show TagBar only when header crosses the top
                        if firstY <= showThreshold {
                            // Disable animation to avoid jump when inset changes
                            withTransaction(Transaction(animation: nil)) {
                                scroll.isOutletHeaderVisible = false
                            }
                        }
                    } else {
                        // Currently TagBar shown; hide it only after header moves comfortably down
                        if firstY > hideThreshold {
                            withTransaction(Transaction(animation: nil)) {
                                scroll.isOutletHeaderVisible = true
                            }
                        }
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            .accessibilityIdentifier("outlet_scroll")

            // Safe area inset reserves space above content when TagBar is shown (no overlap)
            .safeAreaInset(edge: .top) {
                ZStack {
                    if !scroll.isOutletHeaderVisible {
                        TagBar(
                            sections: vm.sections,
                            active: $scroll.activeSection,
                            onTap: { target in
                                guard target != scroll.activeSection else { return }
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    reader.scrollTo(target, anchor: .top)
                                }
                            }
                        )
                        .background(Color(.systemBackground))
                    }
                }
                .frame(height: TAG_BAR_HEIGHT)
            }

            // Also disable implicit animations tied to this state, just in case
            .animation(nil, value: scroll.isOutletHeaderVisible)

            .onAppear {
                CellRegistry.register(kind: .promoCard) { (model: PromoModel) in
                    PromoCard(model: model)
                }
                CellRegistry.register(kind: .dessertCard) { (model: DessertModel) in
                    DessertCard(model: model) { vm.addToCart() }
                }
                
                // Only load if not already preloaded
                if vm.sections.isEmpty {
                    vm.load()
                }
            }
            .onReceive(vm.$sections) { sections in
                if scroll.activeSection == nil, let first = sections.first {
                    scroll.activeSection = first.id
                }
            }
        }
    }
}


#Preview {
    NavigationView {
        OutletView()
            .navigationTitle("Outlet POC")
            .navigationBarTitleDisplayMode(.inline)
    }
}
