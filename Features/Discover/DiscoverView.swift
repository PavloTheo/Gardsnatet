//
//  DiscoverView.swift
//  Gardsnatet
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import SwiftData
import SwiftUI

struct DiscoverView: View {
    @StateObject private var viewModel: DiscoverViewModel

    private let favoriteProducerService: FavoriteProducerServing

    init(viewModel: DiscoverViewModel, favoriteProducerService: FavoriteProducerServing) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.favoriteProducerService = favoriteProducerService
    }

    private var searchTextBinding: Binding<String> {
        Binding(
            get: { viewModel.searchText },
            set: { viewModel.searchText = $0 }
        )
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                ProgressView("Loading producers...")
            case .failed(let message):
                ContentUnavailableView("Discover", systemImage: "leaf", description: Text(message))
            case .loaded:
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        headerCard
                        filterPanel
                        producerResults
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .appScreenBackground()
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.load()
        }
        .onAppear {
            viewModel.refreshFavoriteProducerIDs()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Swedish craft drinks, directly from the source.")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(Color.cardBackground)

            Text("Browse vineyard, brewery, cider house, and meadery profiles built for local pickup and small-batch discovery.")
                .font(.subheadline)
                .foregroundStyle(Color.cardBackground.opacity(0.78))

            Text("\(viewModel.producers.count) producers in the demo network")
                .font(.footnote.weight(.semibold))
                .appInverseBadge()
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appHeroPanel()
        .padding(.top, 12)
    }

    private var filterPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Search by farm or producer", text: searchTextBinding)
                .textFieldStyle(.roundedBorder)
                .tint(Color.primaryBrand)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    categoryChip(title: "All", category: nil)

                    ForEach(ProductCategory.allCases) { category in
                        categoryChip(title: category.title, category: category)
                    }
                }
            }
        }
    }

    private var producerResults: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Featured producers")
                .font(.headline)
                .foregroundStyle(Color.primaryText)

            if viewModel.filteredProducers.isEmpty {
                ContentUnavailableView(
                    "No producers found",
                    systemImage: "magnifyingglass",
                    description: Text("Try changing the search or clearing the current category filter.")
                )
            } else {
                ForEach(viewModel.filteredProducers) { producer in
                    producerRow(for: producer)
                }
            }
        }
    }

    private func categoryChip(title: String, category: ProductCategory?) -> some View {
        let isSelected = viewModel.selectedCategory == category

        return Button {
            viewModel.selectedCategory = category
        } label: {
            Text(title)
                .foregroundStyle(isSelected ? Color.cardBackground : Color.primaryText)
        }
        .buttonStyle(AppChipButtonStyle(isSelected: isSelected))
    }

    private func producerRow(for producer: Producer) -> some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink {
                ProducerDetailView(
                    viewModel: ProducerDetailViewModel(
                        producer: producer,
                        favoriteProducerService: favoriteProducerService
                    )
                )
            } label: {
                producerCard(for: producer)
            }
            .buttonStyle(.plain)

            favoriteButton(for: producer)
                .padding(.top, 16)
                .padding(.trailing, 16)
        }
    }

    private func favoriteButton(for producer: Producer) -> some View {
        let isFavorite = viewModel.isFavorite(producer)

        return Button {
            viewModel.toggleFavorite(for: producer)
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.headline)
                .foregroundStyle(isFavorite ? Color.accentBrand : Color.secondaryText)
                .frame(width: 36, height: 36)
                .background(Color.cardBackground, in: Circle())
                .overlay(
                    Circle()
                        .stroke(Color.subtleBorder.opacity(0.45), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }

    private func producerCard(for producer: Producer) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(producer.name)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.primaryText)

                    Text(producer.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                Text(producer.primaryCategoryTitle)
                    .font(.caption.weight(.semibold))
                    .appBadge()
                    .padding(.trailing, 44)
            }

            Text(producer.story)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .lineLimit(3)

            HStack(spacing: 10) {
                miniMetric("\(producer.products.count)", label: "products")
                miniMetric(producer.products.first?.formattedPrice ?? "-", label: "from")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard()
    }

    private func miniMetric(_ value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primaryText)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
        }
    }
}

#Preview {
    DiscoverPreview()
        .modelContainer(for: FavoriteProducer.self, inMemory: true)
}

private struct DiscoverPreview: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        let favoriteProducerService = AppEnvironment.preview.makeFavoriteProducerService(modelContext)

        DiscoverView(
            viewModel: DiscoverViewModel(
                producerService: MockProducerService(),
                favoriteProducerService: favoriteProducerService
            ),
            favoriteProducerService: favoriteProducerService
        )
    }
}
