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

    @Test func producerCodableUsesNestedCoordinateObject() throws {
        let json = """
        {
          "id": "7B5D4462-9F52-4D25-9C1D-621C2379B701",
          "name": "Skane Barrel House",
          "region": "Skane",
          "story": "Small-batch farmhouse brewery focused on seasonal ales and local grain.",
          "coordinate": {
            "latitude": 55.605,
            "longitude": 13.0038
          },
          "categories": ["beer", "cider"],
          "products": [
            {
              "id": "D6A9E111-70C9-456F-8E75-19F6259D5980",
              "name": "Farmhouse Pale",
              "category": "beer",
              "priceSEK": 59,
              "abv": 5.4,
              "isInStock": true
            }
          ]
        }
        """
        let producer = try JSONDecoder().decode(Producer.self, from: Data(json.utf8))

        #expect(producer.id.uuidString == "7B5D4462-9F52-4D25-9C1D-621C2379B701")
        #expect(producer.coordinate.latitude == 55.605)
        #expect(producer.coordinate.longitude == 13.0038)
        #expect(producer.categories == [.beer, .cider])
        #expect(producer.products.first?.category == .beer)

        let encodedProducer = try JSONDecoder().decode(
            Producer.self,
            from: JSONEncoder().encode(producer)
        )

        #expect(encodedProducer.coordinate.latitude == producer.coordinate.latitude)
        #expect(encodedProducer.coordinate.longitude == producer.coordinate.longitude)
    }

    @Test func bundledProducersCatalogDecodesWithStableIDs() throws {
        let catalogURL = try #require(Bundle.main.url(forResource: "Producers", withExtension: "json"))
        let producers = try JSONDecoder().decode([Producer].self, from: Data(contentsOf: catalogURL))

        assertStableCatalogIDs(in: producers)
    }

    @Test func localJSONProducerServiceLoadsBundledProducers() async throws {
        let service = LocalJSONProducerService()

        let producers = try await service.fetchProducers()

        #expect(producers.count == 3)
        assertStableCatalogIDs(in: producers)
    }

    @Test func localJSONProducerServiceReportsMissingResource() async throws {
        let service = LocalJSONProducerService(resourceName: "MissingProducers")

        do {
            _ = try await service.fetchProducers()
            Issue.record("Expected missing bundled file error.")
        } catch LocalJSONProducerService.ServiceError.missingBundledFile(let resourceName, let resourceExtension) {
            #expect(resourceName == "MissingProducers")
            #expect(resourceExtension == "json")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

private func assertStableCatalogIDs(in producers: [Producer]) {
    #expect(producers.map(\.id.uuidString) == [
        "7B5D4462-9F52-4D25-9C1D-621C2379B701",
        "6C394994-02A3-41D2-8F6B-932A188C46B2",
        "32451E10-8B9C-42E7-90F7-4FB91AA3630D"
    ])

    let productIDs = producers.flatMap { $0.products.map(\.id) }
    #expect(productIDs.map(\.uuidString) == [
        "D6A9E111-70C9-456F-8E75-19F6259D5980",
        "BD3286EC-49F2-4635-9E6C-84016E260AB2",
        "FC63C1C8-E3BF-4E87-932A-E1A1B42AEECF",
        "2B24B07E-7C34-412B-B4BE-7CF7F37F9964",
        "E8C91D7F-14CC-4E32-A084-3C4D119539A5"
    ])
    #expect(Set(productIDs).count == productIDs.count)
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
