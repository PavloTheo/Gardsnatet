//
//  ProducerDetailView.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import SwiftUI
import CoreLocation

struct ProducerDetailView: View {
    @StateObject private var viewModel: ProducerDetailViewModel

    init(viewModel: ProducerDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroSection
                productsSection(title: "Available now", products: viewModel.inStockProducts)

                if !viewModel.outOfStockProducts.isEmpty {
                    productsSection(title: "Coming back", products: viewModel.outOfStockProducts)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.producer.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(viewModel.producer.region.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(viewModel.producer.story)
                .font(.title3.weight(.semibold))

            HStack(spacing: 12) {
                producerMetric(title: "Range", value: viewModel.priceRangeText)
                producerMetric(title: "Products", value: "\(viewModel.producer.products.count)")
                producerMetric(title: "Focus", value: viewModel.producer.categories.map(\.title).joined(separator: ", "))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.80, blue: 0.62),
                    Color(red: 0.76, green: 0.89, blue: 0.74)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
        .padding(.top, 12)
    }

    private func producerMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func productsSection(title: String, products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            ForEach(products) { product in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(product.name)
                            .font(.headline)

                        Spacer()

                        Text(product.formattedPrice)
                            .font(.subheadline.weight(.semibold))
                    }

                    HStack(spacing: 8) {
                        detailBadge(product.category.title)
                        detailBadge("\(product.abv.formatted(.number.precision(.fractionLength(1))))% ABV")
                        detailBadge(product.isInStock ? "In stock" : "Sold out")
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }

    private func detailBadge(_ label: String) -> some View {
        Text(label)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground), in: Capsule())
    }
}

#Preview {
    ProducerDetailView(
        viewModel: ProducerDetailViewModel(
            producer: Producer(
                id: UUID(),
                name: "Preview Producer",
                region: "Skane",
                story: "A small-batch producer with a strong regional identity and a pickup-first operating model.",
                coordinate: CLLocationCoordinate2D(latitude: 55.6050, longitude: 13.0038),
                categories: [.beer, .cider],
                products: [
                    Product(id: UUID(), name: "Farmhouse Pale", category: .beer, priceSEK: 59, abv: 5.4, isInStock: true),
                    Product(id: UUID(), name: "Apple Dry Cider", category: .cider, priceSEK: 64, abv: 6.1, isInStock: false)
                ]
            )
        )
    )
}
