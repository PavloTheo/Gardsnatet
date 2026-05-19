//
//  OrdersView.swift
//  Gardsnatet
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import SwiftUI

struct OrdersView: View {
    @StateObject private var viewModel: OrdersViewModel

    init(viewModel: OrdersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                ProgressView("Loading orders...")
            case .failed(let message):
                ContentUnavailableView("Orders", systemImage: "cart", description: Text(message))
            case .loaded:
                if viewModel.orders.isEmpty {
                    ContentUnavailableView("No orders yet", systemImage: "cart", description: Text("Placed orders will appear here."))
                } else {
                    List(viewModel.orders) { order in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(order.producerName)
                                .font(.headline)

                            Text(order.itemNames.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Text("\(order.status.title) • \(order.totalSEK) SEK")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Orders")
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    OrdersView(viewModel: OrdersViewModel(orderService: MockOrderService()))
}
