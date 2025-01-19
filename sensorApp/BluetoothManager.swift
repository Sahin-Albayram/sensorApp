//
//  BluetoothManager.swift
//  sensorApp
//
//

import Foundation
import CoreBluetooth

/// A class that manages Bluetooth device scanning and connections.
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    /// Published property to hold the list of discovered Bluetooth devices.
    @Published var devices: [CBPeripheral] = []
    
    /// The CBCentralManager instance responsible for managing Bluetooth operations.
    private var centralManager: CBCentralManager?
    
    /// Initializes the Bluetooth manager and starts the CBCentralManager.
    override init() {
        super.init()
        // Initialize the CBCentralManager and set the delegate to self.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    /// Starts scanning for nearby Bluetooth peripherals.
    func startScanning() {
        // Clear any previously discovered devices.
        devices.removeAll()
        // Start scanning for peripherals. Pass 'nil' to scan for all available peripherals.
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /// Stops scanning for Bluetooth peripherals.
    func stopScanning() {
        centralManager?.stopScan()  // Stop scanning for peripherals.
    }
    
    /// Delegate method called when the state of the Bluetooth manager is updated.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
            startScanning()  // Start scanning for devices
        case .poweredOff:

            print("Bluetooth is powered off")
        case .unauthorized:
    
            print("Bluetooth usage is unauthorized")
        case .unsupported:
            
            print("Bluetooth is not supported on this device")
        case .unknown, .resetting:
            
            print("Bluetooth is in an unknown state or resetting")
        @unknown default:
            // A new unknown state was added in a future iOS version.
            print("A new unknown state occurred")
        }
    }
    
    /// Delegate method called when a peripheral is discovered during scanning.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Check if the peripheral is not already in the devices list.
        if !devices.contains(peripheral) {
            // Add the peripheral to the devices list.
            devices.append(peripheral)
        }
    }
}
