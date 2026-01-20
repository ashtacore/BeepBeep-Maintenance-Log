//
//  BeepBeep_Maintenance_LogApp.swift
//  BeepBeep Maintenance Log
//
//  Created by Joshua Runyan on 1/19/26.
//

import SwiftUI
import SwiftData

@main
struct BeepBeep_Maintenance_LogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Vehicle.self, MaintenanceRecord.self])
    }
}
