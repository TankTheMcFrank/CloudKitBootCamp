//
//  CloudKitBootCampApp.swift
//  CloudKitBootCamp
//
//  Created by Frank Herring on 10/4/23.
//

import SwiftUI

@main
struct CloudKitBootCampApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ViewModifierBootcampView()
        }
    }
}
