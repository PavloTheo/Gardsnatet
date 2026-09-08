//
//  MapView.swift
//  Gardsnatet
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import SwiftData
import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: MapViewModel
    @State private var selectedProducer: Producer?

    private let makeFavoriteProducerService: (ModelContext) -> FavoriteProducerServing

    init(
        viewModel: MapViewModel,
        makeFavoriteProducerService: @escaping (ModelContext) -> FavoriteProducerServing
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.makeFavoriteProducerService = makeFavoriteProducerService
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                ProgressView("Loading map...")
            case .failed(let message):
                ContentUnavailableView("Map", systemImage: "map", description: Text(message))
            case .loaded:
                ZStack(alignment: .bottom) {
                    Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedProducerID) {
                        ForEach(viewModel.producers) { producer in
                            Marker(producer.name, coordinate: producer.coordinate)
                                .tint(Color.primaryBrand)
                                .tag(producer.id)
                        }
                    }

                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(viewModel.producers) { producer in
                                    let isSelected = viewModel.selectedProducerID == producer.id

                                    Button {
                                        selectedProducer = producer
                                        viewModel.selectProducer(producer)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(producer.name)
                                                .font(.headline)
                                                .foregroundStyle(Color.primaryText)

                                            Text(producer.region)
                                                .font(.subheadline)
                                                .foregroundStyle(Color.secondaryText)

                                            Text(producer.primaryCategoryTitle)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(isSelected ? Color.accentBrand : Color.secondaryText)
                                        }
                                        .padding(16)
                                        .frame(width: 220, alignment: .leading)
                                        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(isSelected ? Color.primaryBrand : Color.subtleBorder.opacity(0.45), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .id(producer.id)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                        }
                        .onChange(of: viewModel.selectedProducerID) { _, producerID in
                            guard let producerID else { return }
                            viewModel.focusCameraOnSelectedProducer()
                            withAnimation(.easeInOut) {
                                proxy.scrollTo(producerID, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Map")
        .task {
            await viewModel.load()
        }
        .sheet(item: $selectedProducer) { producer in
            NavigationStack {
                ProducerDetailView(
                    viewModel: ProducerDetailViewModel(
                        producer: producer,
                        favoriteProducerService: makeFavoriteProducerService(modelContext)
                    )
                )
            }
        }
    }
}

#Preview {
    MapView(
        viewModel: MapViewModel(producerService: MockProducerService()),
        makeFavoriteProducerService: AppEnvironment.preview.makeFavoriteProducerService
    )
    .modelContainer(for: FavoriteProducer.self, inMemory: true)
}
