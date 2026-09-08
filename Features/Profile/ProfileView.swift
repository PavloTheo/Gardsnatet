//
//  ProfileView.swift
//  Gardsnatet
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import SwiftData
import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle, .loading:
                ProgressView("Loading profile...")
            case .failed(let message):
                ContentUnavailableView("Profile", systemImage: "person.crop.circle", description: Text(message))
            case .loaded:
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let profile = viewModel.profile {
                            accountCard(profile: profile)
                            roleSwitcher

                            if viewModel.presentedRole == .seller {
                                SellerDashboardView(snapshot: viewModel.sellerSnapshot)
                            } else {
                                buyerSummary(profile: profile)
                            }
                        } else {
                            ContentUnavailableView(
                                "No profile is available",
                                systemImage: "person.crop.circle.badge.exclamationmark"
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .appScreenBackground()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.load()
        }
        .onAppear {
            Task {
                await viewModel.refreshFavoriteProducerCount()
            }
        }
    }

    private func accountCard(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(profile.name)
                .font(.title.weight(.bold))
                .foregroundStyle(Color.cardBackground)

            Text("\(profile.region) • Demo marketplace account")
                .font(.subheadline)
                .foregroundStyle(Color.cardBackground.opacity(0.78))

            HStack(spacing: 12) {
                profileBadge(title: "Default role", value: profile.role.rawValue.capitalized)
                profileBadge(title: "Favorites", value: "\(viewModel.favoriteProducerCount)")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appHeroPanel()
        .padding(.top, 12)
    }

    private var roleSwitcher: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Demo role")
                .font(.headline)
                .foregroundStyle(Color.primaryText)

            Picker("Demo role", selection: $viewModel.presentedRole) {
                ForEach(UserRole.allCases) { role in
                    Text(role.rawValue.capitalized).tag(role)
                }
            }
            .pickerStyle(.segmented)
            .tint(Color.primaryBrand)

            Text("Use this switch to present both sides of the marketplace in a single prototype build.")
                .font(.footnote)
                .foregroundStyle(Color.secondaryText)
        }
    }

    private func buyerSummary(profile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buyer snapshot")
                .font(.headline)
                .foregroundStyle(Color.primaryText)

            VStack(alignment: .leading, spacing: 10) {
                Text("This side of the prototype focuses on discovery, filtering, and reviewing producers before pickup.")
                    .foregroundStyle(Color.secondaryText)

                HStack(spacing: 12) {
                    profileBadge(title: "Saved producers", value: "\(viewModel.favoriteProducerCount)")
                    profileBadge(title: "Region", value: profile.region)
                }
            }
            .padding(20)
            .appCard()
        }
    }

    private func profileBadge(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.cardBackground.opacity(0.68), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.subtleBorder.opacity(0.35), lineWidth: 1)
        )
    }
}

#Preview {
    ProfilePreview()
        .modelContainer(for: FavoriteProducer.self, inMemory: true)
}

private struct ProfilePreview: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ProfileView(
            viewModel: ProfileViewModel(
                profileService: MockProfileService(),
                producerService: MockProducerService(),
                favoriteProducerService: AppEnvironment.preview.makeFavoriteProducerService(modelContext)
            )
        )
    }
}
