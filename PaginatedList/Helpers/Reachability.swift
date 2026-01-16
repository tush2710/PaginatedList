//
//  Reachability.swift
//  PaginatedList
//
//  Created by Tushar Zade on 16/01/26.
//
import Network

class Reachability {
    static func isConnectedToNetwork() -> Bool {
        let monitor = NWPathMonitor()
        var isConnected = false
        let semaphore = DispatchSemaphore(value: 0)
        
        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            semaphore.signal()
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        _ = semaphore.wait(timeout: .now() + 1)
        monitor.cancel()
        
        return isConnected
    }
}
