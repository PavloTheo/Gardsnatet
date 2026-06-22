//
//  AppEnvironment.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import Foundation
import SwiftData

struct AppEnvironment {
    let producerService: ProducerServing
    let orderService: OrderServing
    let profileService: ProfileServing
    let makeFavoriteProducerService: (ModelContext) -> FavoriteProducerServing

    static let live = AppEnvironment(
        producerService: MockProducerService(),
        orderService: MockOrderService(),
        profileService: MockProfileService(),
        makeFavoriteProducerService: SwiftDataFavoriteProducerService.init(modelContext:)
    )

    static let preview = live
}
