//
//  HeartbeatStatsView.swift
//  sensorApp
//
import SwiftUI

struct HeartbeatStatsView: View {
    @ObservedObject var viewModel: HeartbeatViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Heartbeat Statistics")
                .font(.largeTitle)
            
            if let stats = viewModel.getStatistics() {
                Text("Mean: \(String(format: "%.2f", stats.mean)) BPM")
                Text("Standard Deviation: \(String(format: "%.2f", stats.std)) BPM")
                Text("Max: \(stats.max) BPM")
                Text("Min: \(stats.min) BPM")
            } else {
                Text("Not enough data to compute statistics")
            }
        }
        .padding()
    }
}

#Preview {
    HeartbeatStatsView(viewModel: HeartbeatViewModel())
}
