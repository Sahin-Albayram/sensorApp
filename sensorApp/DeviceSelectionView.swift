//
//  DeviceSelectionView.swift
//  sensorApp
//

import SwiftUI
import CoreBluetooth

/// A SwiftUI view that allows the user to select a Bluetooth device for monitoring.
struct DeviceSelectionView: View {
    /// The Bluetooth manager that handles device scanning and connections.
    @ObservedObject var bluetoothManager = BluetoothManager()
    
    /// The currently selected device for monitoring.
    @State private var selectedDevice: String? = nil
    
    /// Boolean flag indicating whether the app is currently monitoring a device.
    @State private var isMonitoring = false
    
    var body: some View {
        // NavigationView to manage navigation stack and device selection
        NavigationView {
            VStack {
                Text("Select Device")
                    .font(.largeTitle)
                    .padding()
                
                // List displaying the available devices
                List {
                    // Test Device section (example device)
                    Section(header: Text("Test Device")) {
                        Button(action: {
                            self.selectedDevice = "Test Device"
                            self.isMonitoring = true
                        }) {
                            HStack {
                                Text("Test Device")
                                    .font(.title2)
                                Spacer()
                                if selectedDevice == "Test Device" {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    // Discovered Devices section (actual devices found through Bluetooth)
                    Section(header: Text("Discovered Devices")) {
                        // Iterate through the discovered devices and display them in a list
                        ForEach(bluetoothManager.devices, id: \.identifier) { device in
                            Button(action: {
                                // Update the selected device and start monitoring
                                self.selectedDevice = device.name ?? "Unknown Device"
                                self.isMonitoring = true
                            }) {
                                HStack {
                                    // Display the device name
                                    Text(device.name ?? "Unknown Device")
                                        .font(.title2)
                                    
                                    Spacer()
                                    
                                    // Display a checkmark if this device is selected
                                    if selectedDevice == device.name {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Button to manually refresh the list of discovered devices
                Button(action: {
                    bluetoothManager.startScanning()
                }) {
                    Text("Refresh Devices")
                        .font(.title2)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.top)
                
                Spacer()
                
                // Hidden NavigationLink that triggers when a device is selected
                NavigationLink(
                    destination: ContentView(),
                    isActive: $isMonitoring,
                    label: {
                        EmptyView()
                    }
                )
                .hidden() // Hide the NavigationLink itself
            }
            .padding()
            // Start scanning for devices when the view appears
            .onAppear {
                bluetoothManager.startScanning()
            }
        }
    }
}

#Preview {
    DeviceSelectionView()
}
