//
//  LocalJSONProducerService.swift
//  Gardsnatet
//
//  Created by Codex on 2026-08-04.
//

import Foundation

struct LocalJSONProducerService: ProducerServing {
    enum ServiceError: Error, Equatable {
        case missingBundledFile(resourceName: String, resourceExtension: String)
        case unreadableData(URL)
        case decodingFailed(URL)
    }

    private let bundle: Bundle
    private let resourceName: String
    private let resourceExtension: String
    private let decoder: JSONDecoder
    private let dataLoader: (URL) throws -> Data

    init(
        bundle: Bundle = .main,
        resourceName: String = "Producers",
        resourceExtension: String = "json",
        decoder: JSONDecoder = JSONDecoder(),
        dataLoader: @escaping (URL) throws -> Data = { try Data(contentsOf: $0) }
    ) {
        self.bundle = bundle
        self.resourceName = resourceName
        self.resourceExtension = resourceExtension
        self.decoder = decoder
        self.dataLoader = dataLoader
    }

    func fetchProducers() async throws -> [Producer] {
        guard let catalogURL = bundle.url(forResource: resourceName, withExtension: resourceExtension) else {
            throw ServiceError.missingBundledFile(
                resourceName: resourceName,
                resourceExtension: resourceExtension
            )
        }

        let data: Data
        do {
            data = try dataLoader(catalogURL)
        } catch {
            throw ServiceError.unreadableData(catalogURL)
        }

        do {
            return try decoder.decode([Producer].self, from: data)
        } catch {
            throw ServiceError.decodingFailed(catalogURL)
        }
    }
}
