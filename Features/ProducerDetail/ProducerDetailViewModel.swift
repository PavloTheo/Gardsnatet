//
//  ProducerDetailViewModel.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import Foundation

@MainActor
final class ProducerDetailViewModel: ObservableObject {
    let producer: Producer
    @Published private(set) var isFavorite = false

    private let favoriteProducerService: FavoriteProducerServing

    init(producer: Producer, favoriteProducerService: FavoriteProducerServing) {
        self.producer = producer
        self.favoriteProducerService = favoriteProducerService
        loadFavoriteState()
    }

    func loadFavoriteState() {
        isFavorite = (try? favoriteProducerService.isFavorite(producerID: producer.id)) ?? false
    }

    func toggleFavorite() {
        guard let newFavoriteState = try? favoriteProducerService.toggleFavorite(producerID: producer.id) else { return }
        isFavorite = newFavoriteState
    }

    var inStockProducts: [Product] {
        producer.products.filter(\.isInStock)
    }

    var outOfStockProducts: [Product] {
        producer.products.filter { !$0.isInStock }
    }

    var priceRangeText: String {
        let prices = producer.products.map(\.priceSEK).sorted()

        guard let minimum = prices.first, let maximum = prices.last else {
            return "No pricing available"
        }

        if minimum == maximum {
            return "\(minimum) SEK"
        }

        return "\(minimum)-\(maximum) SEK"
    }
}
