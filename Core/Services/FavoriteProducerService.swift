//
//  FavoriteProducerService.swift
//  Gardsnatet
//
//  Created by Codex on 2026-05-19.
//

import Foundation
import SwiftData

protocol FavoriteProducerServing {
    func fetchFavoriteProducerIDs() throws -> Set<UUID>
    func fetchFavoriteProducerIDs(validFor validProducerIDs: Set<UUID>) throws -> Set<UUID>
    func isFavorite(producerID: UUID) throws -> Bool
    func addFavorite(producerID: UUID) throws
    func removeFavorite(producerID: UUID) throws
    func removeFavorites(notIn validProducerIDs: Set<UUID>) throws
    @discardableResult func toggleFavorite(producerID: UUID) throws -> Bool
}

struct SwiftDataFavoriteProducerService: FavoriteProducerServing {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchFavoriteProducerIDs() throws -> Set<UUID> {
        Set(try fetchFavoriteProducers().map(\.producerID))
    }

    func fetchFavoriteProducerIDs(validFor validProducerIDs: Set<UUID>) throws -> Set<UUID> {
        try removeFavorites(notIn: validProducerIDs)
        return try fetchFavoriteProducerIDs().intersection(validProducerIDs)
    }

    func isFavorite(producerID: UUID) throws -> Bool {
        try favoriteProducer(for: producerID) != nil
    }

    func addFavorite(producerID: UUID) throws {
        guard try !isFavorite(producerID: producerID) else { return }

        modelContext.insert(FavoriteProducer(producerID: producerID))
        try modelContext.save()
    }

    func removeFavorite(producerID: UUID) throws {
        guard let favorite = try favoriteProducer(for: producerID) else { return }

        modelContext.delete(favorite)
        try modelContext.save()
    }

    func removeFavorites(notIn validProducerIDs: Set<UUID>) throws {
        let favorites = try fetchFavoriteProducers()
        let orphanFavorites = favorites.filter { !validProducerIDs.contains($0.producerID) }

        guard !orphanFavorites.isEmpty else { return }

        for favorite in orphanFavorites {
            modelContext.delete(favorite)
        }
        try modelContext.save()
    }

    @discardableResult
    func toggleFavorite(producerID: UUID) throws -> Bool {
        if try isFavorite(producerID: producerID) {
            try removeFavorite(producerID: producerID)
            return false
        }

        try addFavorite(producerID: producerID)
        return true
    }

    private func fetchFavoriteProducers() throws -> [FavoriteProducer] {
        let descriptor = FetchDescriptor<FavoriteProducer>()
        return try modelContext.fetch(descriptor)
    }

    private func favoriteProducer(for producerID: UUID) throws -> FavoriteProducer? {
        var descriptor = FetchDescriptor<FavoriteProducer>(
            predicate: #Predicate { favoriteProducer in
                favoriteProducer.producerID == producerID
            }
        )
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first
    }
}
