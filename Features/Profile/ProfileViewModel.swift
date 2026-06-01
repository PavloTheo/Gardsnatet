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
    private let favoriteProducerService: FavoriteProducerServing

    init(profileService: ProfileServing, favoriteProducerService: FavoriteProducerServing) {
        self.profileService = profileService
        self.favoriteProducerService = favoriteProducerService
    }

    func load() async {
        guard profile == nil else {
            refreshFavoriteProducerCount()
            return
        }
        loadState = .loading

        do {
            profile = try await profileService.fetchProfile()
            if let profile {
                presentedRole = profile.role
            }
            refreshFavoriteProducerCount()
            loadState = .loaded
        } catch {
            loadState = .failed("Could not load profile.")
        }
    }

    func refreshFavoriteProducerCount() {
        favoriteProducerCount = (try? favoriteProducerService.fetchFavoriteProducerIDs().count) ?? 0
    }

    var sellerSnapshot: SellerDashboardSnapshot {
        .preview
    }
}
