//
//  DataCollectionView.swift
//  sensorApp
//

import SwiftUI

/// View that allows users to collect heartbeat data for a set duration and save/share it as a CSV.
struct DataCollectionView: View {
    @ObservedObject var viewModel: HeartbeatViewModel  // ViewModel to manage heartbeat data
    @State private var isCollecting = false  // Flag to indicate if data collection is in progress
    @State private var countdown = 60  // Countdown timer for data collection (60 seconds)
    @State private var collectedData: [HeartbeatData] = []  // Array to store collected heartbeat data
    @State private var timer: Timer? = nil  // Timer to manage the countdown and data collection

    var body: some View {
        VStack(spacing: 20) {
            Text("Data Collection")
                .font(.largeTitle)
            
            Text("Press the button below to collect data for 1 minute.")
                .multilineTextAlignment(.center)
                .padding()
            
        
            if isCollecting {
                Text("Time Remaining: \(countdown) seconds")
                    .font(.title2)
                    .bold()
            } else {
                Text("Collected \(collectedData.count) entries.")
                    .font(.title2)
            }
            
            // Start/Stop data collection button
            Button(action: {
                if !isCollecting {
                    startDataCollection()  // Start data collection if not already collecting
                }
            }) {
                Text(isCollecting ? "Collecting..." : "Start Collection")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isCollecting ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isCollecting)  // Disable button while collecting data
            
            // Show the share CSV button if data collection is complete and data exists
            if !isCollecting && !collectedData.isEmpty {
                Button(action: {
                    shareCSVFile()
                }) {
                    Text("Share CSV")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    /// Starts the data collection process.
    func startDataCollection() {
        isCollecting = true
        countdown = 60  // default 60 seconds
        collectedData.removeAll()
        
        // Start a timer that collects data every second
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                // Add the latest heartbeat data to the collectedData array
                let newData = HeartbeatData(timestamp: Date(), heartbeat: viewModel.heartbeat)
                collectedData.append(newData)
                countdown -= 1  // Decrease the countdown
            } else {
                // Stop the timer when the countdown reaches zero and save the data
                timer?.invalidate()
                timer = nil
                isCollecting = false  // Set collecting flag to false
                saveDataToCSV()  // Save collected data to a CSV file
            }
        }
    }
    
    /// Saves the collected data to a CSV file.
    func saveDataToCSV() {
        // Loop through all collected data and save each entry to the CSV file
        for data in collectedData {
            viewModel.writeToCSV(heartbeatData: data)
        }
        print("Data saved to CSV.")
    }
    
    /// Shares the CSV file containing the collected heartbeat data.
    func shareCSVFile() {
        // Get the file URL for the CSV file in the app's document directory
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let fileURL = paths[0].appendingPathComponent("heartbeat_data.csv")
        
        // Check if the file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("CSV file not found!")
            return
        }
        
        // Create a UIActivityViewController to share the CSV file
        let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)  // Present the sharing sheet
        }
    }
}

#Preview {
    DataCollectionView(viewModel: HeartbeatViewModel())
}
