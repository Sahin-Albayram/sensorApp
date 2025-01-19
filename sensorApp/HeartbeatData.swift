//
//  HeartbeatData.swift
//  sensorApp
//

import Foundation

struct HeartbeatData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let heartbeat: Int
}

struct HeartbeatDataJson: Codable {
    let timestamp: String
    let heartbeat: Int
}
