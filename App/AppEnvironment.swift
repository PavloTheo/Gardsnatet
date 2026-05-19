//
//  AppEnvironment.swift
//  Gardsnatet
//
//  Created by Codex on 2025-08-26.
//

import Foundation

struct AppEnvironment {
    let producerService: ProducerServing
    let orderService: OrderServing
    let profileService: ProfileServing

    static let live = AppEnvironment(
        producerService: MockProducerService(),
        orderService: MockOrderService(),
        profileService: MockProfileService()
    )

    static let preview = live
}
