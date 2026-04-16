//
//  MarketplaceServices.swift
//  GardsNatetProtoTest
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

struct MockProducerService: ProducerServing {
    func fetchProducers() async throws -> [Producer] {
        [
            Producer(
                id: UUID(),
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
                id: UUID(),
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
                id: UUID(),
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
