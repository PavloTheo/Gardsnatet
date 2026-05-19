//
//  MapView.swift
//  Gardsnatet
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel: MapViewModel
    @State private var selectedProducer: Producer?

    init(viewModel: MapViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                    Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.producers) { producer in
                        MapMarker(coordinate: producer.coordinate)
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(viewModel.producers) { producer in
                                Button {
                                    selectedProducer = producer
                                    viewModel.region.center = producer.coordinate
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(producer.name)
                                            .font(.headline)

                                        Text(producer.region)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        Text(producer.primaryCategoryTitle)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(16)
                                    .frame(width: 220, alignment: .leading)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
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
                ProducerDetailView(viewModel: ProducerDetailViewModel(producer: producer))
            }
        }
    }
}

#Preview {
    MapView(viewModel: MapViewModel(producerService: MockProducerService()))
}
