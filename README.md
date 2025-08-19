# PickMe Foods – View Architecture

A tiny, presentation‑ready SwiftUI POC of the **Outlet and Foods Home** screen for the PickMe Foods vertical (Uber‑Eats style).  
Focus areas: high‑performance rendering, low‑boilerplate cell/view generation, easy evolution, and robust UI behavior.

---

## Highlights

- **Composable UI schema** → sections + items drive the whole screen.
- **Registry‑based cell factory** → add new cell types without touching switch statements.
- **Stateless MVVM** (immutable inputs, explicit outputs).
- **Sticky TagBar with hysteresis** → smooth, flicker‑free show/hide while scrolling.
- **Mixed layouts** → vertical lists + horizontal carousels (promos/desserts).
- **Testing hooks** → accessibility IDs everywhere + “monkey” UI tests.
- **Performance guardrails** → stable IDs, minimal recompute, and stress harness.

---

## Folder Structure

```
OutletPOC/
├─ Domain/
│  ├─ SectionKind.swift
│  ├─ LayoutStyle.swift
│  ├─ ItemKind.swift
│  ├─ SectionSchema.swift
│  └─ ItemSchema.swift
├─ Models/
│  ├─ MenuItemModel.swift
│  ├─ PromoModel.swift
│  └─ DessertModel.swift
├─ Rendering/
│  ├─ CellRegistry.swift
│  └─ SectionRenderer.swift
├─ Coordination/
│  ├─ ScrollCoordinator.swift
│  └─ SectionHeaderOffsetKey.swift
└─ Screens/
   ├─ OutletView.swift
   └─ TagBar.swift
```

---

## UI Architecture

### 1) Schema‑Driven Composition
- **SectionSchema** declares:
  - `id: SectionKind`, `headerTitle`, `layout: LayoutStyle`, `isSticky`, `items: [ItemSchema]`
- **ItemSchema** declares:
  - `kind: ItemKind`, `model: AnyHashable` (type‑erased payload)

> New sections or cells = add enum case + builder, no OutletView changes.

### 2) Registry‑Based Cell Factory
- **CellRegistry** is a lightweight factory: `ItemKind → (Model) -> View`.
- Register once (e.g., in `onAppear`) and **build** cells at render time.
- Benefits: isolates cell construction, kills large `switch`es, testable in isolation.

### 3) Stateless MVVM (POC‑simple)
- `OutletPOCViewModel` holds **value‑type state** (`sections`, `cartCount`) and exposes simple actions (`load()`, `addToCart()`).
- Views subscribe via `@StateObject` but treat the VM as immutable inputs most of the time.
- Easy to mock/DI in tests or a stress harness.

### 4) Scroll Coordination (sticky + active section)
- **PreferenceKey** (`SectionHeaderOffsetKey`) collects every **section header** Y‑offset in one pass.
- We compute:
  - **activeSection**: which header is nearest the top (for TagBar highlighting).
  - **isOutletHeaderVisible**: using the **first section header** position + hysteresis.
- **Hysteresis** (two thresholds) prevents flicker when you hover near the boundary.

### 5) Sticky TagBar (no flicker, no gap)
- **Show/Hide trigger**: derived from the **first section header**’s `minY` with hysteresis.
- **Top inset**: we reserve TagBar height via `safeAreaInset(edge: .top)` (constant height); the content never jumps.
- **Exact height**: either use a measured height or the tuned constant (we currently use **36pt**).

### 6) Layouts
- **Vertical**: `LayoutStyle.list` — simple `VStack` of `MenuItemCell`s.
- **Horizontal**: `LayoutStyle.horizontalCard(size:)` — `ScrollView(.horizontal)` + fixed card size.
  - **Promotions**: 150×200
  - **Desserts**: 150×300 + “Add” button

---

## Design Patterns Used

- **Composite**: screen = sections = items; hierarchical composition of views.
- **Abstract Factory (Registry)**: `CellRegistry` maps `ItemKind → builder` (typed factories under the hood).
- **Strategy**: `LayoutStyle` encodes layout strategy (list vs. horizontal).
- **MVVM (stateless lean)**: VM is a state holder and action surface; views render from value state.
- **Observer**: SwiftUI `@Published` + `@StateObject` for reactive updates.

---

## Key Files & Concepts

### `OutletView.swift`
- Hosts the vertical `ScrollView` + `LazyVStack(pinnedViews: [.sectionHeaders])`.
- Publishes section header offsets via `SectionHeaderOffsetKey`.
- Derives:
  - `scroll.activeSection` (TagBar highlight)
  - `scroll.isOutletHeaderVisible` (TagBar show/hide with hysteresis)
- Adds a **constant** top inset (36pt) with `safeAreaInset` and renders `TagBar`.

### `TagBar.swift`
- Horizontal chip scroller.
- Active chip = filled `Capsule`; inactive chip = stroked `Capsule`.
- Tapping a chip triggers `ScrollViewReader.scrollTo(sectionID, anchor: .top)`.

### `SectionRenderer.swift`
- Renders each section according to `layout`.
- Adds **accessibility IDs** for horizontal scrollers and cards:
  - `promos_scroller`, `promo_card_<idx>`
  - `desserts_scroller`, `dessert_card_<idx>`  
  (Dessert “Add”: `dessert_add_btn` inside card)

### `CellRegistry.swift`
- `register(kind:builder:)` to add typed builders.
- `build(_:)` returns `AnyView` for a given `ItemSchema`.

---

## Accessibility & Testability

- **Vertical scroll**: `.accessibilityIdentifier("outlet_scroll")`
- **Tag chips**: `"tag_<SectionKind>"` (or `"tag_<title>_<idx>"` in stress)
- **Horizontal scrollers**: `"promos_scroller"`, `"desserts_scroller"`
- **Cards**: `"promo_card_<idx>"`, `"dessert_card_<idx>"`
- **Cart count**: `"cart_count"`

These stable IDs make UI tests deterministic and keep selectors simple.

---

## UI Testing (XCTest)

### Launch Flags
- `UITEST_OUTLET_POC` → route app directly to the Outlet POC screen.
- `UITEST_STRESS` → launch stress harness (lots of sections/items).
- `DISABLE_ANIMATIONS` → turn off UIKit animations during tests.

> Add these under **Scheme → Test → Arguments Passed On Launch**.

### Example Tests
- **Visibility**: scroll until TagBar appears, scroll up to hide (assert hittability).
- **Navigation**: tap “Dinner” chip → `Dinner` header pinned at top.
- **Monkey**: rapid fling up/down + random chip tapping.
- **Horizontal**: stress `promos_scroller` & `desserts_scroller`, tap Dessert “Add” repeatedly and assert `cart_count` increments.
- **Perf**: `XCTClockMetric`, `XCTCPUMetric`, `XCTMemoryMetric` loops for smoothness and regressions.
- **Hitch metric** (iOS 15+): `XCTOSSignpostMetric.scrollHitchesMetric`.

> First perf run: **Set Baseline** in Xcode’s test report for comparisons.

---

## Performance Practices

- **Stable identity**: `SectionSchema`/`ItemSchema` are `Identifiable` & `Hashable` (hash by `id`).
- **Minimal work in `onPreferenceChange`**: only hysteresis + boolean flip.
- **Avoid layout thrash**: constant TagBar height (no reflow), stable pinned stack.
- **No heavy work in cell `body`**; precompute models, keep views light.
- **Stress harness** (optional): inject huge datasets + automated scroll/taps to surface jank.

---

## How to Run

1. Open the project in Xcode.
2. Run the app — it launches into the Outlet POC by default (or route via `@main` if you have a different root).
3. **(Optional) Stress mode**  
   - Edit **Run Scheme** → add `UITEST_STRESS` to **Arguments Passed On Launch**.  
   - Run — you’ll see the stress view/data.
4. **Run UI Tests**  
   - Select the UI test scheme (or your app scheme with tests) and press **⌘U**.  
   - Set performance baselines after the first successful run if you want comparisons.

---

## Adding a New Cell Type (2 mins)

1. Add a case to `ItemKind` (e.g., `.badge`).
2. Create your view `BadgeCell`.
3. Register a builder:
   ```swift
   CellRegistry.register(kind: .badge) { (model: BadgeModel) in
       BadgeCell(model: model)
   }
   ```
4. Push an `ItemSchema(kind: .badge, model: BadgeModel(...))` in any section’s `items`.

No `switch` gymnastics in `OutletView`.

---

## License

Internal POC for PickMe Foods. © PickMe. All rights reserved.
