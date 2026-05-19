//
//  OrdersViewModel.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import Foundation

@MainActor
final class OrdersViewModel: ObservableObject {
    @Published private(set) var loadState: LoadState = .idle
    @Published private(set) var orders: [Order] = []

    private let orderService: OrderServing

    init(orderService: OrderServing) {
        self.orderService = orderService
    }

    func load() async {
        guard orders.isEmpty else { return }
        loadState = .loading

        do {
            orders = try await orderService.fetchOrders()
            loadState = .loaded
        } catch {
            loadState = .failed("Could not load orders.")
        }
    }
}
