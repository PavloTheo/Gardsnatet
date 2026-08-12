# Gardsnatet

Gardsnatet is a SwiftUI portfolio prototype for a Swedish farm-to-consumer marketplace focused on small-scale wine, beer, cider, and mead producers.

The app explores a two-sided marketplace where buyers can discover local producers, browse regional offerings, view pickup-based order information, and switch into a seller-facing dashboard concept for managing limited inventory and fulfillment.

> This is a portfolio prototype, not a production marketplace or live alcohol sales platform. The domain is used to explore local discovery, regulated product presentation, marketplace UX, and SwiftUI architecture.

## Portfolio Summary

Gardsnatet was built as a product-oriented SwiftUI prototype to demonstrate how a real marketplace concept could be structured from an iOS development perspective. The project focuses on clean feature separation, local JSON-backed catalog loading, buyer and seller journeys, and a domain model that supports local discovery, producer storytelling, order overview, and seller inventory concepts. The goal is not to ship a complete commercial app, but to present a realistic, expandable foundation for a modern SwiftUI application.

## Screens

| Discover | Profile / Seller Mode | Producer Detail |
| --- | --- | --- |
| ![Discover screen](Docs/Screenshots/discover.png) | ![Profile screen](Docs/Screenshots/profile.png) | ![Producer detail screen](Docs/Screenshots/producer-detail.png) |

## Demo

A short simulator walkthrough GIF/video is planned.

Suggested future demo flow:

1. Browse producers on the Discover screen.
2. Open a producer detail page.
3. View available products and pickup-oriented information.
4. Switch to the Profile tab.
5. Open the seller dashboard concept.
6. Review inventory and order-related seller information.

## What It Demonstrates

- Feature-oriented SwiftUI project structure
- MVVM-style screen organization
- Protocol-based services
- Shared app environment for dependency injection
- Codable producer and product catalog loading from bundled JSON
- Buyer flow for local producer discovery
- Persistent producer favorites backed by SwiftData
- SwiftData-backed user state with cleanup for orphaned favorite records
- Map-based browsing concept
- Order overview and fulfillment status modeling
- Producer detail pages with story, products, and availability
- Seller-facing dashboard concept inside the profile flow
- Portfolio-oriented product thinking and iterative roadmap planning

## Tech Stack

- Swift
- SwiftUI
- SwiftData
- MVVM
- Xcode
- XCTest
- Protocol-based service layer
- Bundled local JSON catalog data
- Swift concurrency-ready service abstractions

Implemented technical features:

- Bundled `Producers.json` catalog loaded by `LocalJSONProducerService`
- Codable `Producer` and `Product` models
- Nested latitude/longitude coordinate decoding for producers
- Stable producer and product IDs in the bundled catalog
- Persistent producer favorites using SwiftData
- Favorite state shared across Discover, Producer Detail, and Profile
- Stable ID-based persistence for saved producers
- Orphan favorite cleanup for stale persisted rows
- Focused unit tests for JSON decoding, service loading, favorite persistence, and valid favorite counting

Planned technical additions:

- Expanded async/await usage
- Modern iOS 17+ SwiftUI Map APIs
- Broader unit test coverage for view models and core flows

## Architecture

The project is organized around a feature-first structure with shared domain models and services.

```text
Gardsnatet/
├── App/
├── Core/
│   ├── Data/
│   ├── Models/
│   ├── Persistence/
│   ├── Services/
│   └── Support/
└── Features/
    ├── Discover/
    ├── Map/
    ├── Orders/
    ├── ProducerDetail/
    └── Profile/
```
### App

The `App` layer contains the app entry point, root tab structure, and shared environment composition.

### Core

The `Core` layer contains reusable domain and infrastructure code.

- `Core/Models`
  - Marketplace domain models such as `Producer`, `Product`, `Order`, and seller dashboard types.

- `Core/Services`
  - Service protocols, bundled JSON catalog loading, mock preview fixtures, and SwiftData-backed favorite persistence used to keep the prototype modular and easy to expand.

- `Core/Data`
  - Bundled catalog resources such as `Producers.json`.

- `Core/Support`
  - Shared utility types such as `LoadState`.

### Features

The `Features` layer contains screen-specific SwiftUI views and view models.

- `Features/Discover`
  - Discovery feed, filters, producer cards, and favorite controls.

- `Features/Map`
  - Map browsing and producer selection.

- `Features/Orders`
  - Order list and status overview.

- `Features/ProducerDetail`
  - Producer story, pricing range, product availability, favorite state, and detail presentation.

- `Features/Profile`
  - Buyer profile, persisted saved-producer count, and demo seller dashboard mode.

## Architecture Decisions

### Feature-first organization

The app is organized by user-facing features rather than by technical type alone. This makes the project easier to navigate as it grows and keeps related views, view models, and feature logic close together.

### MVVM-style presentation logic

Each major screen uses a dedicated view model where appropriate. This keeps SwiftUI views focused on layout and interaction while allowing filtering, loading, and presentation logic to be tested separately.

### Protocol-based services

The prototype uses service protocols so screens depend on abstractions rather than concrete data sources. The live producer catalog is loaded from bundled JSON, while small deterministic mock fixtures remain available for SwiftUI previews and focused tests. This keeps the app simple to run locally and leaves a clean path toward a backend-backed implementation later.

### Bundled catalog and local user state

Producer and product catalog data comes from `Core/Data/Producers.json`, decoded through `LocalJSONProducerService`. User-specific favorites are separate persisted state stored with SwiftData by stable `Producer.id` values. This keeps shared catalog data and per-user saved state from being coupled.

### SwiftData-backed user state

Producer catalog data and user-specific saved state are intentionally kept separate. Producers are loaded through the app’s service layer, while favorited producer IDs are persisted locally using SwiftData. View models depend on a `FavoriteProducerServing` protocol rather than SwiftData directly, keeping persistence details isolated and easier to test.

### SwiftData-backed favorites

Producer favorites are persisted locally with SwiftData and stored by stable `Producer.id` values. Favorite state is available from Discover producer cards and Producer Detail, survives app relaunch, and is reflected in the Profile saved-producer count. The favorite service also filters and cleans up orphaned favorite rows whose stored producer IDs no longer match the current producer data.

### Shared app environment

Shared dependencies are composed near the app root and passed into feature flows. This keeps the prototype flexible and avoids tightly coupling screens to concrete data sources.

### Prototype-first scope

The app intentionally focuses on demonstrating structure, product thinking, and expandable flows instead of pretending to be a production-ready marketplace. This keeps the project realistic and makes the roadmap clear.

## Current Product Direction

Gardsnatet is centered on:

- Small-batch Swedish producers
- Local and regional discovery
- Producer storytelling
- Pickup-first ordering rather than large-scale fulfillment
- Limited product availability
- Buyer and seller perspectives inside a single demo build

## Regulatory / Domain Note

This project uses wine, beer, cider, and mead as a marketplace domain because the category creates interesting design and product constraints around local discovery, inventory, pickup logistics, and regulated product presentation.

The app is not intended to represent a live alcohol sales service, bypass existing alcohol regulations, or provide a complete legal/commercial model. In a production scenario, this domain would require careful handling of Swedish alcohol laws, age verification, licensing, fulfillment rules, and platform compliance.

## Running The Project

1. Open `Gardsnatet.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Build and run the `Gardsnatet` scheme.

The app currently loads producer and product catalog data from bundled JSON, while order and profile data remain mock-backed. Favorites are stored locally with SwiftData. No backend setup is required.

## Testing

Unit tests live in `GardsnatetTests`.

Current test coverage is intentionally light and focused on view model filtering, bundled JSON decoding/loading, and SwiftData favorite persistence cleanup. The test suite is planned to expand alongside seller dashboard features.

## Roadmap

### Near-term

- Expand view model unit tests
- Update map implementation to newer iOS 17+ `Map` APIs
- Improve screenshots with simulator-framed images or a short walkthrough GIF
- Add a dedicated saved producers list or filter view

### Medium-term

- Expand seller tools with local inventory editing
- Add pickup window management
- Add richer order state transitions
- Improve empty, loading, and error states
- Add accessibility labels and Dynamic Type checks

### Production Considerations

If developed beyond prototype stage, the app would need:

- Real authentication
- Backend-backed producer and product data
- Secure user accounts
- Age verification
- Region-specific legal compliance
- Payment and order infrastructure
- Moderation/admin tooling
- Robust error handling
- Analytics and observability
- App Store compliance review for regulated products

## What I Would Add In Production

For a production-grade version, I would separate the buyer and seller experiences more clearly, introduce authentication, connect the service layer to a backend, and add a compliance-aware product model. I would also expand order handling beyond static mock states into a full lifecycle covering reservation, confirmation, pickup scheduling, cancellation, and seller-side inventory updates.

The current architecture is designed so these additions could be introduced gradually without rewriting the entire app structure.

## Status

Gardsnatet is an active portfolio project.

The current goal is to turn the prototype into a polished, well-documented SwiftUI case study that demonstrates product thinking, clean architecture, and practical iOS development skills.
