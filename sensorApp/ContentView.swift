//
//  ContentView.swift
//  sensorApp
//

import SwiftUI

/// The main content view for the sensorApp, consisting of a tab view with multiple sections.
struct ContentView: View {
    /// The ViewModel instance that manages the heartbeat data.
    @ObservedObject var viewModel = HeartbeatViewModel()
    
    var body: some View {
        // TabView to provide a tab-based navigation structure.
        TabView {
            // Tab 1: Heartbeat Monitor List View
            HeartbeatListView(viewModel: viewModel)
                .tabItem {
                    Label("Monitor", systemImage: "heart.fill") // Tab label and icon
                }
            
            // Tab 2: Heartbeat Chart View
            HeartbeatChartView(viewModel: viewModel)
                .tabItem {
                    Label("Chart", systemImage: "waveform.path.ecg") // Tab label and icon
                }
            
            // Tab 3: Heartbeat Statistics View
            HeartbeatStatsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill") // Tab label and icon
                }
            
            // Tab 4: Data Collection View
            DataCollectionView(viewModel: viewModel)
               .tabItem {
                   Label("Collect Data", systemImage: "tray.and.arrow.down.fill") // Tab label and icon
               }
        }
    }
}

/// A view that displays a list of heartbeat data and the current heartbeat.
struct HeartbeatListView: View {
    /// The ViewModel instance for this view.
    @ObservedObject var viewModel: HeartbeatViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Heartbeat Monitor")
                .font(.largeTitle)
            
            Text("Current Heartbeat:")
                .font(.title2)
            
            Text("\(viewModel.heartbeat) BPM")
                .font(.system(size: 64))
                .bold()
            
            List(viewModel.data) { data in
                HStack {
                    Text("\(data.timestamp, formatter: Self.dateFormatter)")
                    Spacer()

                    Text("\(data.heartbeat) BPM")
                }
            }
        }
        .padding()
    }
    
    // Date formatter to format the timestamp in the list.
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}

#Preview {
    ContentView() // Previews the ContentView
}
