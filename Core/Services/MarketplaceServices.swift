//
//  MarketplaceServices.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import Foundation
import CoreLocation

protocol ProducerServing {
    func fetchProducers() async throws -> [Producer]
}

protocol OrderServing {
    func fetchOrders() async throws -> [Order]
}

protocol ProfileServing {
    func fetchProfile() async throws -> UserProfile
}

private enum MockProducerFixtureIDs {
    static let previewHopLab = UUID(uuid: (0x10, 0x01, 0xA0, 0x01, 0x11, 0x11, 0x4A, 0xAA, 0x80, 0x01, 0x10, 0x01, 0xA0, 0x01, 0x00, 0x01))
    static let previewOrchardLab = UUID(uuid: (0x10, 0x01, 0xA0, 0x02, 0x22, 0x22, 0x4B, 0xBB, 0x80, 0x02, 0x10, 0x01, 0xA0, 0x02, 0x00, 0x02))

    static let testPale = UUID(uuid: (0x20, 0x02, 0xB0, 0x01, 0x11, 0x11, 0x4A, 0xAA, 0x90, 0x01, 0x20, 0x02, 0xB0, 0x01, 0x00, 0x01))
    static let testCider = UUID(uuid: (0x20, 0x02, 0xB0, 0x02, 0x22, 0x22, 0x4B, 0xBB, 0x90, 0x02, 0x20, 0x02, 0xB0, 0x02, 0x00, 0x02))
}

struct MockProducerService: ProducerServing {
    func fetchProducers() async throws -> [Producer] {
        [
            Producer(
                id: MockProducerFixtureIDs.previewHopLab,
                name: "Preview Hop Lab",
                region: "Test Region North",
                story: "Synthetic preview brewery used for UI fixtures and focused tests.",
                coordinate: CLLocationCoordinate2D(latitude: 59.3346, longitude: 18.0632),
                categories: [.beer],
                products: [
                    Product(
                        id: MockProducerFixtureIDs.testPale,
                        name: "Fixture Pale Ale",
                        category: .beer,
                        priceSEK: 50,
                        abv: 5.0,
                        isInStock: true
                    )
                ]
            ),
            Producer(
                id: MockProducerFixtureIDs.previewOrchardLab,
                name: "Preview Orchard Lab",
                region: "Test Region South",
                story: "Synthetic preview cidery used to exercise category filtering and empty-state transitions.",
                coordinate: CLLocationCoordinate2D(latitude: 55.6049, longitude: 13.0038),
                categories: [.cider, .mead],
                products: [
                    Product(
                        id: MockProducerFixtureIDs.testCider,
                        name: "Fixture Dry Cider",
                        category: .cider,
                        priceSEK: 65,
                        abv: 6.2,
                        isInStock: true
                    )
                ]
            )
        ]
    }
}

struct MockOrderService: OrderServing {
    func fetchOrders() async throws -> [Order] {
        [
            Order(
                id: UUID(),
                producerName: "Skane Barrel House",
                itemNames: ["Farmhouse Pale", "Apple Dry Cider"],
                totalSEK: 123,
                status: .confirmed
            ),
            Order(
                id: UUID(),
                producerName: "Gotland Vineyard Co.",
                itemNames: ["North Sea Brut"],
                totalSEK: 215,
                status: .readyForPickup
            )
        ]
    }
}

struct MockProfileService: ProfileServing {
    func fetchProfile() async throws -> UserProfile {
        UserProfile(
            id: UUID(),
            name: "Pavlo",
            role: .buyer,
            region: "Stockholm",
            favoriteProducerIDs: []
        )
    }
}
