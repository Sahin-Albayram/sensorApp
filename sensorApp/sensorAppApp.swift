//
//  sensorAppApp.swift
//  sensorApp
//

import SwiftUI

/// The main entry point of the sensorApp.
@main
struct sensorAppApp: App {
    /// The main body of the application, defining the root scene.
    var body: some Scene {
        // The window group is the container for the app's user interface.
        WindowGroup {
            // Sets the initial view of the application to DeviceSelectionView.
            DeviceSelectionView()
        }
    }
}
