//
//  HeartbeatChartView.swift
//  sensorApp
//

import SwiftUI
import Charts

/// A SwiftUI view that displays a chart of recent heartbeat data.
struct HeartbeatChartView: View {
    /// The view model that provides heartbeat data for the chart.
    @ObservedObject var viewModel: HeartbeatViewModel
    
    var body: some View {
        VStack {
            Text("Heartbeat Chart")
                .font(.largeTitle)
            
            // Chart displaying the most recent 10 data points
            Chart {
                // Iterate over the last 10 heartbeat data points
                ForEach(viewModel.data.suffix(10)) { data in
                    LineMark(
                        x: .value("Time", data.timestamp),
                        y: .value("Heartbeat", data.heartbeat)
                    )
                    
                    .foregroundStyle(.red)
                }
            }
            .frame(height: 300)
            .padding()
        }
    }
}

#Preview {
    // Preview with a sample HeartbeatViewModel
    HeartbeatChartView(viewModel: HeartbeatViewModel())
}
