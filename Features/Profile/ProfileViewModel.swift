//
//  ProfileViewModel.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var loadState: LoadState = .idle
    @Published private(set) var profile: UserProfile?
    @Published private(set) var favoriteProducerCount = 0
    @Published var presentedRole: UserRole = .buyer

    private let profileService: ProfileServing
    private let producerService: ProducerServing
    private let favoriteProducerService: FavoriteProducerServing

    init(
        profileService: ProfileServing,
        producerService: ProducerServing,
        favoriteProducerService: FavoriteProducerServing
    ) {
        self.profileService = profileService
        self.producerService = producerService
        self.favoriteProducerService = favoriteProducerService
    }

    func load() async {
        guard profile == nil else {
            await refreshFavoriteProducerCount()
            return
        }
        loadState = .loading

        do {
            profile = try await profileService.fetchProfile()
            if let profile {
                presentedRole = profile.role
            }
            await refreshFavoriteProducerCount()
            loadState = .loaded
        } catch {
            loadState = .failed("Could not load profile.")
        }
    }

    func refreshFavoriteProducerCount() async {
        do {
            let validProducerIDs = Set(try await producerService.fetchProducers().map(\.id))
            favoriteProducerCount = try favoriteProducerService.fetchFavoriteProducerIDs(validFor: validProducerIDs).count
        } catch {
            favoriteProducerCount = 0
        }
    }

    var sellerSnapshot: SellerDashboardSnapshot {
        .preview
    }
}
