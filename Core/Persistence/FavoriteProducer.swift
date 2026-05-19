//
//  FavoriteProducer.swift
//  Gardsnatet
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

@Model
final class FavoriteProducer {
    @Attribute(.unique) var producerID: UUID
    var createdAt: Date

    init(producerID: UUID, createdAt: Date = .now) {
        self.producerID = producerID
        self.createdAt = createdAt
    }
}
