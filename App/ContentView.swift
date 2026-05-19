//
//  ContentView.swift
//  Gardsnatet
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import SwiftUI

struct ContentView: View {
    private let environment: AppEnvironment

    init(environment: AppEnvironment = .preview) {
        self.environment = environment
    }

    var body: some View {
        TabView {
            NavigationStack {
                DiscoverView(
                    viewModel: DiscoverViewModel(producerService: environment.producerService)
                )
            }
            .tabItem {
                Label("Discover", systemImage: "leaf")
            }

            NavigationStack {
                MapView(
                    viewModel: MapViewModel(producerService: environment.producerService)
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
                    viewModel: ProfileViewModel(profileService: environment.profileService)
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
}
