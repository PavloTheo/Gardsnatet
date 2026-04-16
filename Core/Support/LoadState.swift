//
//  LoadState.swift
//  GardsNatetProtoTest
//
//  Created by Codex on 2025-08-26.
//

import Foundation

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)
}
