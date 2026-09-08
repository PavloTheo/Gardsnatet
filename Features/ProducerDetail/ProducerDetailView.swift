//
//  ProducerDetailView.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import SwiftData
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
        .appScreenBackground()
        .navigationTitle(viewModel.producer.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(viewModel.isFavorite ? Color.accentBrand : Color.primaryBrand)
            }
            .accessibilityLabel(viewModel.isFavorite ? "Remove from favorites" : "Add to favorites")
        }
        .onAppear {
            viewModel.loadFavoriteState()
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(viewModel.producer.region.uppercased())
                .appSectionLabel()
                .foregroundStyle(Color.cardBackground.opacity(0.74))

            Text(viewModel.producer.story)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.cardBackground)

            HStack(spacing: 12) {
                producerMetric(title: "Range", value: viewModel.priceRangeText)
                producerMetric(title: "Products", value: "\(viewModel.producer.products.count)")
                producerMetric(title: "Focus", value: viewModel.producer.categories.map(\.title).joined(separator: ", "))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appHeroPanel()
        .padding(.top, 12)
    }

    private func producerMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.cardBackground.opacity(0.74))

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.cardBackground)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func productsSection(title: String, products: [Product]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.primaryText)

            ForEach(products) { product in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(product.name)
                            .font(.headline)
                            .foregroundStyle(Color.primaryText)

                        Spacer()

                        Text(product.formattedPrice)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.primaryBrand)
                    }

                    HStack(spacing: 8) {
                        detailBadge(product.category.title)
                        detailBadge("\(product.abv.formatted(.number.precision(.fractionLength(1))))% ABV")
                        detailBadge(product.isInStock ? "In stock" : "Sold out")
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard()
            }
        }
    }

    private func detailBadge(_ label: String) -> some View {
        Text(label)
            .font(.caption.weight(.medium))
            .appBadge()
    }
}

#Preview {
    NavigationStack {
        ProducerDetailPreview()
    }
    .modelContainer(for: FavoriteProducer.self, inMemory: true)
}

private struct ProducerDetailPreview: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
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
                ),
                favoriteProducerService: AppEnvironment.preview.makeFavoriteProducerService(modelContext)
            )
        )
    }
}
