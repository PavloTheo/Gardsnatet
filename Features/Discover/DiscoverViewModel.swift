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
    @Published private(set) var favoriteProducerIDs: Set<UUID> = []

    private let producerService: ProducerServing
    private let favoriteProducerService: FavoriteProducerServing

    init(producerService: ProducerServing, favoriteProducerService: FavoriteProducerServing) {
        self.producerService = producerService
        self.favoriteProducerService = favoriteProducerService
    }

    var filteredProducers: [Producer] {
        producers.filter { producer in
            let matchesSearch = searchText.isEmpty || producer.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || producer.categories.contains(selectedCategory!)
            return matchesSearch && matchesCategory
        }
    }

    func load() async {
        guard producers.isEmpty else {
            refreshFavoriteProducerIDs()
            return
        }
        loadState = .loading

        do {
            producers = try await producerService.fetchProducers()
            refreshFavoriteProducerIDs()
            loadState = .loaded
        } catch {
            loadState = .failed("Could not load producers.")
        }
    }

    func refreshFavoriteProducerIDs() {
        favoriteProducerIDs = (try? favoriteProducerService.fetchFavoriteProducerIDs()) ?? []
    }

    func isFavorite(_ producer: Producer) -> Bool {
        favoriteProducerIDs.contains(producer.id)
    }

    func toggleFavorite(for producer: Producer) {
        guard let newFavoriteState = try? favoriteProducerService.toggleFavorite(producerID: producer.id) else { return }

        if newFavoriteState {
            favoriteProducerIDs.insert(producer.id)
        } else {
            favoriteProducerIDs.remove(producer.id)
        }
    }
}
