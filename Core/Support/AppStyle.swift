//
//  AppStyle.swift
//  Gardsnatet
//
//  Created by Codex on 2026-09-08.
//

import SwiftUI

extension Color {
    static let appBackground = Color(red: 0.96, green: 0.94, blue: 0.87)
    static let primaryBrand = Color(red: 0.08, green: 0.23, blue: 0.16)
    static let accentBrand = Color(red: 0.67, green: 0.46, blue: 0.18)
    static let primaryText = Color(red: 0.13, green: 0.13, blue: 0.12)
    static let secondaryText = Color(red: 0.36, green: 0.36, blue: 0.31)
    static let cardBackground = Color(red: 0.99, green: 0.98, blue: 0.93)
    static let subtleBorder = Color(red: 0.72, green: 0.67, blue: 0.56)
}

extension View {
    func appScreenBackground() -> some View {
        background(Color.appBackground)
    }

    func appCard(cornerRadius: CGFloat = 8) -> some View {
        background(Color.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.subtleBorder.opacity(0.45), lineWidth: 1)
            )
    }

    func appHeroPanel(cornerRadius: CGFloat = 8) -> some View {
        background(Color.primaryBrand, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.accentBrand.opacity(0.35), lineWidth: 1)
            )
    }

    func appBadge(isEmphasized: Bool = false) -> some View {
        padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                isEmphasized ? Color.primaryBrand : Color.accentBrand.opacity(0.16),
                in: Capsule()
            )
            .foregroundStyle(isEmphasized ? Color.cardBackground : Color.primaryBrand)
    }

    func appInverseBadge() -> some View {
        padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.cardBackground.opacity(0.12), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.accentBrand.opacity(0.45), lineWidth: 1)
            )
            .foregroundStyle(Color.cardBackground)
    }

    func appSectionLabel() -> some View {
        font(.caption.weight(.semibold))
            .textCase(.uppercase)
            .tracking(0.8)
            .foregroundStyle(Color.secondaryText)
    }
}

struct AppChipButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected ? Color.primaryBrand : Color.cardBackground,
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.primaryBrand : Color.subtleBorder.opacity(0.45), lineWidth: 1)
            )
            .foregroundStyle(isSelected ? Color.cardBackground : Color.primaryText)
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}
