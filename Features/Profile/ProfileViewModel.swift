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
    @Published var presentedRole: UserRole = .buyer

    private let profileService: ProfileServing

    init(profileService: ProfileServing) {
        self.profileService = profileService
    }

    func load() async {
        guard profile == nil else { return }
        loadState = .loading

        do {
            profile = try await profileService.fetchProfile()
            if let profile {
                presentedRole = profile.role
            }
            loadState = .loaded
        } catch {
            loadState = .failed("Could not load profile.")
        }
    }

    var sellerSnapshot: SellerDashboardSnapshot {
        .preview
    }
}
