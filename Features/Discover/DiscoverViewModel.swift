//
//  DiscoverViewModel.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import Foundation

@MainActor
final class DiscoverViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: ProductCategory?
    @Published private(set) var loadState: LoadState = .idle
    @Published private(set) var producers: [Producer] = []

    private let producerService: ProducerServing

    init(producerService: ProducerServing) {
        self.producerService = producerService
    }

    var filteredProducers: [Producer] {
        producers.filter { producer in
            let matchesSearch = searchText.isEmpty || producer.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || producer.categories.contains(selectedCategory!)
            return matchesSearch && matchesCategory
        }
    }

    func load() async {
        guard producers.isEmpty else { return }
        loadState = .loading

        do {
            producers = try await producerService.fetchProducers()
            loadState = .loaded
        } catch {
            loadState = .failed("Could not load producers.")
        }
    }
}
