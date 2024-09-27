//
//  LovUApp.swift
//  LovU
//
//  Created by Vinnicius Pereira on 27/09/24.
//

import SwiftUI

@main
struct LovUApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
