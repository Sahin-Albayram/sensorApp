//
//  HeartbeatViewModel.swift
//  sensorApp
//

import Foundation
import Combine
import SwiftUI
import ScoscheSDK24
import CoreBluetooth

/// ViewModel responsible for managing heartbeat data and interactions with the Scosche SDK.
class HeartbeatViewModel: ObservableObject {
    /// Published property to store the latest heartbeat value.
    @Published var heartbeat: Int = 0
    
    /// Array to store collected heartbeat data.
    @Published var data = [HeartbeatData]()
    
    /// Set to manage Combine subscriptions and avoid memory leaks.
    private var cancellables = Set<AnyCancellable>()
    
    /// Reference to the connected Scosche monitor.
    private var monitor: ScoscheMonitor?
    
    /// ViewController to interact with Scosche SDK for BLE functionality.
    private var monitorView = SchoscheViewController()
    
    /// Initializer to set up Bluetooth observers or start dummy data simulation.
    init() {
        // Uncomment the following lines to enable Bluetooth functionality with the Scosche SDK:
        // setupBluetoothObservers()
        // startScanning()
        
        // Start fetching random dummy data for testing.
        startFetchingDummyData()
    }
    
    /// Starts generating random heartbeat data for testing purposes.
    func startFetchingDummyData() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // Generate a random heartbeat value between 60 and 100.
                let randomHeartbeat = Int.random(in: 60...100)
                self.heartbeat = randomHeartbeat
                
                // Create a new data point with the current timestamp and random heartbeat value.
                let heartbeatData = HeartbeatData(timestamp: Date(), heartbeat: randomHeartbeat)
                self.data.append(heartbeatData)
                
                // Write the new data point to a CSV file.
                self.writeToCSV(heartbeatData: heartbeatData)
            }
            .store(in: &cancellables) // Store the subscription to manage its lifecycle.
    }
    
    /// Calculates statistics (mean, standard deviation, max, min) for the last 10 heartbeat data points.
    func getStatistics() -> (mean: Double, std: Double, max: Int, min: Int)? {
        guard data.count >= 10 else { return nil } // Ensure there are at least 10 data points.
        let recentData = data.suffix(10).map { $0.heartbeat }
        
        let mean = recentData.map { Double($0) }.reduce(0.0, +) / Double(recentData.count)
        let std = sqrt(recentData.map { pow(Double($0) - mean, 2) }.reduce(0, +) / Double(recentData.count))
        let max = recentData.max() ?? 0
        let min = recentData.min() ?? 0
        
        return (mean, std, max, min)
    }
    
    /// Sets up Bluetooth observers for receiving data and handling Bluetooth-related events.
    func setupBluetoothObservers() {
        // Initialize Bluetooth observers with the Scosche SDK.
        ScoscheSDK24.setupBluetoothObservers(monitorView: monitorView)
        
        // Define the callback to handle updates from the Bluetooth device.
        monitorView.onBluetoothDataUpdate = { [weak self] characteristic in
            guard let self = self else { return }
            
            // Extract heart rate data from the characteristic, if available.
            if let heartRateData = self.extractHeartRate(from: characteristic) {
                DispatchQueue.main.async {
                    // Update the heartbeat value and append the new data point.
                    self.heartbeat = heartRateData
                    let dataPoint = HeartbeatData(timestamp: Date(), heartbeat: heartRateData)
                    self.data.append(dataPoint)
                    
                    // Write the new data point to a CSV file.
                    self.writeToCSV(heartbeatData: dataPoint)
                }
            }
        }
    }
    
    /// Writes a heartbeat data point to a CSV file in the app's document directory.
    func writeToCSV(heartbeatData: HeartbeatData) {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let fileURL = documentsDirectory.appendingPathComponent("heartbeat_data.csv")
        
        print("CSV File Path: \(fileURL.path)") // Debugging: Log the file path.
        
        let csvText = "\(heartbeatData.timestamp),\(heartbeatData.heartbeat)\n"
        
        if !fileManager.fileExists(atPath: fileURL.path) {
            // Create a new file if it doesn't exist.
            do {
                try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("Failed to create file: \(error.localizedDescription)")
            }
        } else {
            // Append data to the existing file.
            do {
                let fileHandle = try FileHandle(forWritingTo: fileURL)
                fileHandle.seekToEndOfFile()
                if let data = csvText.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
            } catch {
                print("Failed to write to file: \(error.localizedDescription)")
            }
        }
    }
    
    /// Starts scanning for Scosche devices using the SDK.
    func startScanning() {
        ScoscheDeviceScan(monitorView: monitorView)
    }
    
    /// Connects to the selected Scosche monitor.
    func connectToDevice(selectedMonitor: ScoscheMonitor) {
        ScoscheDeviceConnect(monitor: selectedMonitor, monitorView: monitorView)
        monitor = selectedMonitor
    }
    
    /// Extracts the heart rate value from a Bluetooth characteristic.
    func extractHeartRate(from characteristic: CBUUID) -> Int? {
        // Ensure the characteristic UUID matches the Heart Rate Measurement characteristic.
        let heartRateUUID = CBUUID(string: "2A37")
        guard characteristic == heartRateUUID else {
            return nil
        }
        
        // Simulating received data for demonstration purposes.
        let simulatedData: Data = Data([0x06, 0x48]) // Example raw data.
        
        // Parse the first byte (flags) to determine the data format.
        let flags = simulatedData[0]
        let isHeartRateInUINT16 = (flags & 0x01) != 0
        
        // Parse the heart rate value based on the format.
        if isHeartRateInUINT16 {
            // Heart rate is in the 2nd and 3rd bytes.
            let heartRate = UInt16(simulatedData[1]) | (UInt16(simulatedData[2]) << 8)
            return Int(heartRate)
        } else {
            // Heart rate is in the 2nd byte.
            let heartRate = simulatedData[1]
            return Int(heartRate)
        }
    }
}
