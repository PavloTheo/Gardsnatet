//
//  GardsNatetProtoTestApp.swift
//  GardsNatetProtoTest
//
//  Created by Pavlo Theodoridis on 2025-05-15.
//

import SwiftUI

@main
struct GardsNatetProtoTestApp: App {
    private let environment = AppEnvironment.live

    var body: some Scene {
        WindowGroup {
            ContentView(environment: environment)
        }
    }
}
