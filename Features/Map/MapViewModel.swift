//
//  MapViewModel.swift
//  GardsNatetProtoTest
//
//  Created by Codex on 2025-08-26.
//

import Foundation
import MapKit

@MainActor
final class MapViewModel: ObservableObject {
    @Published private(set) var loadState: LoadState = .idle
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 59.3346, longitude: 18.0632),
        span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
    )
    @Published private(set) var producers: [Producer] = []

    private let producerService: ProducerServing

    init(producerService: ProducerServing) {
        self.producerService = producerService
    }

    func load() async {
        guard producers.isEmpty else { return }
        loadState = .loading

        do {
            let loadedProducers = try await producerService.fetchProducers()
            producers = loadedProducers
            loadState = .loaded

            if let firstProducer = loadedProducers.first {
                region = MKCoordinateRegion(
                    center: firstProducer.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 6.0, longitudeDelta: 6.0)
                )
            }
        } catch {
            loadState = .failed("Could not load map data.")
        }
    }
}
