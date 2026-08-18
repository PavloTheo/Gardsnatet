//
//  MapViewModel.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import Foundation
import MapKit
import SwiftUI

@MainActor
final class MapViewModel: ObservableObject {
    @Published private(set) var loadState: LoadState = .idle
    @Published var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 59.3346, longitude: 18.0632),
            span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        )
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
                focusCamera(on: firstProducer)
            }
        } catch {
            loadState = .failed("Could not load map data.")
        }
    }

    func focusCamera(on producer: Producer) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: producer.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 6.0, longitudeDelta: 6.0)
            )
        )
    }
}
