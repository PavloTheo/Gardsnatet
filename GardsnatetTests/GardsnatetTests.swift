//
//  GardsnatetTests.swift
//  GardsnatetTests
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import Foundation
import SwiftData
import Testing
@testable import Gardsnatet

struct GardsnatetTests {
    @MainActor
    @Test func discoverViewModelLoadsAndFiltersByCategoryAndSearch() async throws {
        let viewModel = DiscoverViewModel(
            producerService: ProducerServiceStub(),
            favoriteProducerService: FavoriteProducerServiceStub()
        )

        await viewModel.load()

        #expect(viewModel.loadState == .loaded)
        #expect(viewModel.producers.count == 2)

        viewModel.selectedCategory = .beer
        #expect(viewModel.filteredProducers.map(\.name) == ["North Farm Brewery"])

        viewModel.searchText = "apple"
        viewModel.selectedCategory = .cider
        #expect(viewModel.filteredProducers.map(\.name) == ["Apple Hill Cider"])
    }

    @MainActor
    @Test func favoriteProducerServiceRemovesOrphanFavoritesWhenFetchingValidIDs() throws {
        let validProducerID = UUID()
        let orphanProducerID = UUID()
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: FavoriteProducer.self, configurations: configuration)
        let service = SwiftDataFavoriteProducerService(modelContext: ModelContext(container))

        try service.addFavorite(producerID: validProducerID)
        try service.addFavorite(producerID: orphanProducerID)

        let validFavoriteIDs = try service.fetchFavoriteProducerIDs(validFor: [validProducerID])

        #expect(validFavoriteIDs == [validProducerID])
        #expect(try service.fetchFavoriteProducerIDs() == [validProducerID])
    }

    @MainActor
    @Test func profileViewModelCountsOnlyValidFavoriteProducers() async {
        let validProducerID = UUID()
        let orphanProducerID = UUID()
        let favoriteProducerService = FavoriteProducerServiceStub(favoriteProducerIDs: [validProducerID, orphanProducerID])
        let viewModel = ProfileViewModel(
            profileService: MockProfileService(),
            producerService: ProducerServiceStub(producerIDs: [validProducerID]),
            favoriteProducerService: favoriteProducerService
        )

        await viewModel.refreshFavoriteProducerCount()

        #expect(viewModel.favoriteProducerCount == 1)
        #expect(favoriteProducerService.favoriteProducerIDs == [validProducerID])
    }
}

private struct ProducerServiceStub: ProducerServing {
    let producerIDs: [UUID]

    init(producerIDs: [UUID] = [UUID(), UUID()]) {
        self.producerIDs = producerIDs
    }

    func fetchProducers() async throws -> [Producer] {
        [
            Producer(
                id: producerIDs[0],
                name: "North Farm Brewery",
                region: "Jamtland",
                story: "A test brewery.",
                coordinate: .init(latitude: 63.1792, longitude: 14.6357),
                categories: [.beer],
                products: [
                    Product(id: UUID(), name: "Pale Ale", category: .beer, priceSEK: 56, abv: 5.2, isInStock: true)
                ]
            ),
            Producer(
                id: producerIDs.count > 1 ? producerIDs[1] : UUID(),
                name: "Apple Hill Cider",
                region: "Skane",
                story: "A test cidery.",
                coordinate: .init(latitude: 55.9930, longitude: 13.5958),
                categories: [.cider],
                products: [
                    Product(id: UUID(), name: "Apple Reserve", category: .cider, priceSEK: 72, abv: 6.4, isInStock: true)
                ]
            )
        ]
    }
}

private final class FavoriteProducerServiceStub: FavoriteProducerServing {
    var favoriteProducerIDs: Set<UUID>

    init(favoriteProducerIDs: Set<UUID> = []) {
        self.favoriteProducerIDs = favoriteProducerIDs
    }

    func fetchFavoriteProducerIDs() throws -> Set<UUID> {
        favoriteProducerIDs
    }

    func fetchFavoriteProducerIDs(validFor validProducerIDs: Set<UUID>) throws -> Set<UUID> {
        try removeFavorites(notIn: validProducerIDs)
        return favoriteProducerIDs.intersection(validProducerIDs)
    }

    func isFavorite(producerID: UUID) throws -> Bool {
        favoriteProducerIDs.contains(producerID)
    }

    func addFavorite(producerID: UUID) throws {
        favoriteProducerIDs.insert(producerID)
    }

    func removeFavorite(producerID: UUID) throws {
        favoriteProducerIDs.remove(producerID)
    }

    func removeFavorites(notIn validProducerIDs: Set<UUID>) throws {
        favoriteProducerIDs = favoriteProducerIDs.intersection(validProducerIDs)
    }

    func toggleFavorite(producerID: UUID) throws -> Bool {
        if favoriteProducerIDs.contains(producerID) {
            favoriteProducerIDs.remove(producerID)
            return false
        }

        favoriteProducerIDs.insert(producerID)
        return true
    }
}
