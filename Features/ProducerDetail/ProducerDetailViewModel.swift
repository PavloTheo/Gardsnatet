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

    init(producer: Producer) {
        self.producer = producer
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
