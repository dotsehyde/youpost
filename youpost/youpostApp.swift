//
//  youpostApp.swift
//  youpost
//
//  Created by Benjamin. on 12/01/2024.
//

import SwiftUI

@main
struct youpostApp: App {
    @StateObject var viewModel = PostViewModel(service: PostService.shared)
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
