//
//  GardsnatetTests.swift
//  GardsnatetTests
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import Foundation
import Testing
@testable import Gardsnatet

struct GardsnatetTests {
    @MainActor
    @Test func discoverViewModelLoadsAndFiltersByCategoryAndSearch() async throws {
        let viewModel = DiscoverViewModel(producerService: ProducerServiceStub())

        await viewModel.load()

        #expect(viewModel.loadState == .loaded)
        #expect(viewModel.producers.count == 2)

        viewModel.selectedCategory = .beer
        #expect(viewModel.filteredProducers.map(\.name) == ["North Farm Brewery"])

        viewModel.searchText = "apple"
        viewModel.selectedCategory = .cider
        #expect(viewModel.filteredProducers.map(\.name) == ["Apple Hill Cider"])
    }
}

private struct ProducerServiceStub: ProducerServing {
    func fetchProducers() async throws -> [Producer] {
        [
            Producer(
                id: UUID(),
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
                id: UUID(),
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
