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
                .background(Color(.systemGroupedBackground))
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
                .font(.system(.largeTitle, design: .rounded, weight: .bold))

            Text("Browse vineyard, brewery, cider house, and meadery profiles built for local pickup and small-batch discovery.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(viewModel.producers.count) producers in the demo network")
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.83, blue: 0.72),
                    Color(red: 0.82, green: 0.91, blue: 0.79),
                    Color(red: 0.76, green: 0.86, blue: 0.94)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 32, style: .continuous)
        )
        .padding(.top, 12)
    }

    private var filterPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Search by farm or producer", text: searchTextBinding)
                .textFieldStyle(.roundedBorder)

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
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
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
                .foregroundStyle(isFavorite ? Color.accentColor : Color.secondary)
                .frame(width: 36, height: 36)
                .background(.background, in: Circle())
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

                    Text(producer.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(producer.primaryCategoryTitle)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.secondarySystemBackground), in: Capsule())
                    .padding(.trailing, 44)
            }

            Text(producer.story)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack(spacing: 10) {
                miniMetric("\(producer.products.count)", label: "products")
                miniMetric(producer.products.first?.formattedPrice ?? "-", label: "from")
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func miniMetric(_ value: String, label: String) -> some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.subheadline.weight(.semibold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
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
