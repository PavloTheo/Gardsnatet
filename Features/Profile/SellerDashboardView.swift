//
//  SellerDashboardView.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import SwiftUI

struct SellerDashboardView: View {
    let snapshot: SellerDashboardSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(snapshot.shopName.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("Seller dashboard built for local pickup, limited stock, and farm-scale production.")
                    .font(.title3.weight(.semibold))

                Text(snapshot.fulfillmentNote)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.84, green: 0.91, blue: 0.79),
                        Color(red: 0.97, green: 0.87, blue: 0.72)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )

            HStack(spacing: 12) {
                sellerMetric(value: "\(snapshot.openOrders)", label: "open orders")
                sellerMetric(value: "\(snapshot.monthlyRevenueSEK) SEK", label: "this month")
                sellerMetric(value: snapshot.nextPickupWindow, label: "next pickup")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Inventory watch")
                    .font(.headline)

                ForEach(snapshot.inventoryItems) { item in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.headline)

                            Text("\(item.remainingBottles) bottles left • \(item.formattedPrice)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(item.statusLabel)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(item.statusColor.opacity(0.16), in: Capsule())
                            .foregroundStyle(item.statusColor)
                    }
                    .padding(16)
                    .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
            }
        }
    }

    private func sellerMetric(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.headline)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    SellerDashboardView(snapshot: .preview)
        .padding()
        .background(Color(.systemGroupedBackground))
}
