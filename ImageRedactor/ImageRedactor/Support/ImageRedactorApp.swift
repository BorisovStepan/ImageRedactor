//
//  ImageRedactorApp.swift
//  ImageRedactor
//
//  Created by Stepan Borisov on 10.05.25.
//

import SwiftUI
import FirebaseCore

@main
struct ImageRedactorApp: App {
    @StateObject private var router = Router()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(router)
        }
    }
}
