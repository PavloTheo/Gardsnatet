//
//  ContentView.swift
//  Gardsnatet
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    private let environment: AppEnvironment

    init(environment: AppEnvironment = .preview) {
        self.environment = environment
    }

    var body: some View {
        let favoriteProducerService = environment.makeFavoriteProducerService(modelContext)

        TabView {
            NavigationStack {
                DiscoverView(
                    viewModel: DiscoverViewModel(
                        producerService: environment.producerService,
                        favoriteProducerService: favoriteProducerService
                    ),
                    favoriteProducerService: favoriteProducerService
                )
            }
            .tabItem {
                Label("Discover", systemImage: "leaf")
            }

            NavigationStack {
                MapView(
                    viewModel: MapViewModel(producerService: environment.producerService),
                    makeFavoriteProducerService: environment.makeFavoriteProducerService
                )
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                OrdersView(
                    viewModel: OrdersViewModel(orderService: environment.orderService)
                )
            }
            .tabItem {
                Label("Orders", systemImage: "cart")
            }

            NavigationStack {
                ProfileView(
                    viewModel: ProfileViewModel(
                        profileService: environment.profileService,
                        producerService: environment.producerService,
                        favoriteProducerService: favoriteProducerService
                    )
                )
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FavoriteProducer.self, inMemory: true)
}
