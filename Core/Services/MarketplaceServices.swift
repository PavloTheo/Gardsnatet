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

private enum DemoProducerIDs {
    static let skaneBarrelHouse = UUID(uuid: (0x7B, 0x5D, 0x44, 0x62, 0x9F, 0x52, 0x4D, 0x25, 0x9C, 0x1D, 0x62, 0x1C, 0x23, 0x79, 0xB7, 0x01))
    static let gotlandVineyard = UUID(uuid: (0x6C, 0x39, 0x49, 0x94, 0x02, 0xA3, 0x41, 0xD2, 0x8F, 0x6B, 0x93, 0x2A, 0x18, 0x8C, 0x46, 0xB2))
    static let dalarnaMeadery = UUID(uuid: (0x32, 0x45, 0x1E, 0x10, 0x8B, 0x9C, 0x42, 0xE7, 0x90, 0xF7, 0x4F, 0xB9, 0x1A, 0xA3, 0x63, 0x0D))
}

struct MockProducerService: ProducerServing {
    func fetchProducers() async throws -> [Producer] {
        [
            Producer(
                id: DemoProducerIDs.skaneBarrelHouse,
                name: "Skane Barrel House",
                region: "Skane",
                story: "Small-batch farmhouse brewery focused on seasonal ales and local grain.",
                coordinate: CLLocationCoordinate2D(latitude: 55.6050, longitude: 13.0038),
                categories: [.beer, .cider],
                products: [
                    Product(id: UUID(), name: "Farmhouse Pale", category: .beer, priceSEK: 59, abv: 5.4, isInStock: true),
                    Product(id: UUID(), name: "Apple Dry Cider", category: .cider, priceSEK: 64, abv: 6.1, isInStock: true)
                ]
            ),
            Producer(
                id: DemoProducerIDs.gotlandVineyard,
                name: "Gotland Vineyard Co.",
                region: "Gotland",
                story: "Experimental vineyard and cellar producing sparkling wines for local pickup.",
                coordinate: CLLocationCoordinate2D(latitude: 57.6348, longitude: 18.2948),
                categories: [.wine],
                products: [
                    Product(id: UUID(), name: "North Sea Brut", category: .wine, priceSEK: 215, abv: 11.5, isInStock: true),
                    Product(id: UUID(), name: "Rose 2024", category: .wine, priceSEK: 189, abv: 12.0, isInStock: false)
                ]
            ),
            Producer(
                id: DemoProducerIDs.dalarnaMeadery,
                name: "Dalarna Meadery",
                region: "Dalarna",
                story: "Honey-driven meadery pairing traditional recipes with modern fruit blends.",
                coordinate: CLLocationCoordinate2D(latitude: 60.6065, longitude: 15.6355),
                categories: [.mead, .beer],
                products: [
                    Product(id: UUID(), name: "Forest Honey Mead", category: .mead, priceSEK: 142, abv: 8.5, isInStock: true)
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
