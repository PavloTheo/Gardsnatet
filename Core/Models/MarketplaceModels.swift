//
//  MarketplaceModels.swift
//  GardsNatetProtoTest
//
//  Created by Codex on 2025-08-26.
//

import Foundation
import CoreLocation
import SwiftUI

enum UserRole: String, CaseIterable, Identifiable {
    case buyer
    case seller

    var id: String { rawValue }
}

enum ProductCategory: String, CaseIterable, Identifiable {
    case wine
    case beer
    case cider
    case mead

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }
}

enum OrderStatus: String, CaseIterable, Identifiable {
    case pending
    case confirmed
    case readyForPickup = "ready_for_pickup"
    case completed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pending:
            "Pending"
        case .confirmed:
            "Confirmed"
        case .readyForPickup:
            "Ready for Pickup"
        case .completed:
            "Completed"
        }
    }
}

struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: ProductCategory
    let priceSEK: Int
    let abv: Double
    let isInStock: Bool

    var formattedPrice: String {
        "\(priceSEK) SEK"
    }
}

struct Producer: Identifiable, Hashable {
    let id: UUID
    let name: String
    let region: String
    let story: String
    let coordinate: CLLocationCoordinate2D
    let categories: [ProductCategory]
    let products: [Product]

    var subtitle: String {
        "\(region) • \(categories.map(\.title).joined(separator: ", "))"
    }

    var primaryCategoryTitle: String {
        categories.first?.title ?? "Local Producer"
    }
}

extension Producer {
    static func == (lhs: Producer, rhs: Producer) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Order: Identifiable, Hashable {
    let id: UUID
    let producerName: String
    let itemNames: [String]
    let totalSEK: Int
    let status: OrderStatus
}

struct UserProfile: Identifiable, Hashable {
    let id: UUID
    let name: String
    let role: UserRole
    let region: String
    let favoriteProducerIDs: [UUID]
}

struct SellerInventoryItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let remainingBottles: Int
    let priceSEK: Int

    var formattedPrice: String {
        "\(priceSEK) SEK"
    }

    var statusLabel: String {
        remainingBottles <= 12 ? "Low stock" : "Healthy"
    }

    var statusColor: Color {
        remainingBottles <= 12 ? .orange : .green
    }
}

struct SellerDashboardSnapshot: Hashable {
    let shopName: String
    let monthlyRevenueSEK: Int
    let openOrders: Int
    let nextPickupWindow: String
    let fulfillmentNote: String
    let inventoryItems: [SellerInventoryItem]
}

extension SellerDashboardSnapshot {
    static let preview = SellerDashboardSnapshot(
        shopName: "Skane Barrel House",
        monthlyRevenueSEK: 18420,
        openOrders: 12,
        nextPickupWindow: "Sat 11:00",
        fulfillmentNote: "Most orders are grouped into two pickup windows each week to keep operations simple for small producers.",
        inventoryItems: [
            SellerInventoryItem(id: UUID(), name: "Farmhouse Pale", remainingBottles: 42, priceSEK: 59),
            SellerInventoryItem(id: UUID(), name: "Apple Dry Cider", remainingBottles: 9, priceSEK: 64)
        ]
    )
}
