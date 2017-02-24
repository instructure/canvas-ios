//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import Foundation
import SystemConfiguration
import ReactiveSwift


open class RegionPicker: NSObject {
    
    open static let betaURL = URL(string: "https://airwolf-iad-gamma.inscloudgate.net/")!
    
    fileprivate static let prodRegions = [
        URL(string: "https://airwolf-iad-prod.instructure.com")!,
        URL(string: "https://airwolf-dub-prod.instructure.com")!,
        URL(string: "https://airwolf-syd-prod.instructure.com")!,
        URL(string: "https://airwolf-sin-prod.instructure.com")!,
        URL(string: "https://airwolf-fra-prod.instructure.com")!
    ]
    
    open var defaultURL: URL {
        return RegionPicker.prodRegions[0]
    }
    
    open let beta = MutableProperty<Bool>(false)

    open static let defaultPicker = RegionPicker()

    fileprivate (set) internal var completion: (URL?)->Void = { _ in }

    fileprivate var pingers: [String: SimplePing] = [:]

    fileprivate var responseTimes: [String: [Double]] = [:]
    fileprivate var averageResponseTimes: [String: Double] = [:]
    fileprivate var pingStartTimes: [String: Date] = [:]
    fileprivate var pingerTimeoutTimers: [String: Timer] = [:]

    override public init() {
        super.init()

        // Don't ping prod when we're testing the UI.
        if NSClassFromString("EarlGreyImpl") != nil { return }

        for region in RegionPicker.prodRegions {
            let pinger = SimplePing(hostName: region.host!)
            pinger.delegate = self
            pingers[region.host!] = pinger

            responseTimes[region.host!] = []
        }
    }

    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

    internal(set) open var pickedRegionURL: URL? {
        set {
            if beta.value { return } // don't alter the picked region when using beta
            UserDefaults.standard.set(newValue, forKey: "picked-region")
        } get {
            if beta.value { return RegionPicker.betaURL } // only ever use beta when its turned on
            return UserDefaults.standard.url(forKey: "picked-region")
        }
    }

    open func setRegionToDefault() {
        pickedRegionURL = RegionPicker.prodRegions[0]
    }

    open func pickBestRegion(_ completion: @escaping (URL?)->Void) {
        self.completion = completion
        if isConnectedToNetwork() {
            for (_, pinger) in pingers.enumerated() {
                // Stop it if it's going and restart it
                pinger.1.stop()
                pinger.1.start()
            }
        } else {
            completion(nil)
        }
    }

    fileprivate func record(responseTime: Double, forHost host: String) {
        guard var hostResponseTimes = responseTimes[host] else { return }
        hostResponseTimes.append(responseTime)
        responseTimes[host] = hostResponseTimes
        print("Adding response time: \(responseTime) forHost: \(host)")

        if let timeoutTimer = pingerTimeoutTimers[host] {
            timeoutTimer.invalidate()
            pingerTimeoutTimers[host] = nil
        }

        if hostResponseTimes.count >= 5 {
            pingers[host]?.stop()
            let average = (hostResponseTimes as NSArray).value(forKeyPath: "@avg.self") as! NSNumber
            averageResponseTimes[host] = average.doubleValue

            print("5 or more recorded response times for host: \(host) with average of: \(average)")

            if averageResponseTimes.keys.count == RegionPicker.prodRegions.count {
                // We have averages for each - time to make a decision!
                for (_, pinger) in pingers.enumerated() {
                    // Stop it if it's going
                    pinger.1.stop()

                }

                for (_, timer) in pingerTimeoutTimers {
                    timer.invalidate()
                }
                pingerTimeoutTimers.removeAll()

                let smallestResponseTime = ((averageResponseTimes as NSDictionary).allValues as NSArray).value(forKeyPath: "@min.self") as! NSNumber
                let key = (averageResponseTimes as NSDictionary).allKeys(for: smallestResponseTime.doubleValue).first! as! String

                let url = URL(string: "https://\(key)")!
                print("\(url) region picked with lowest latency: \(smallestResponseTime)")

                pickedRegionURL = url
                completion(url)
            }
        } else {
            // If we don't have 3 yet, send another
            pingers[host]?.send(with: nil)
        }
    }
}

extension RegionPicker: SimplePingDelegate {
    public func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        // Start the ping immediately
        pinger.send(with: nil)
    }

    public func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        pingStartTimes[pinger.hostName] = Date()
        pingerTimeoutTimers[pinger.hostName] = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timeoutTriggered(_:)), userInfo: ["host": pinger.hostName], repeats: false)
    }

    public func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        record(responseTime: 1000, forHost: pinger.hostName)
    }

    public func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        record(responseTime: 1000, forHost: pinger.hostName)
    }

    public func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let startTime = pingStartTimes[pinger.hostName] else { return }
        let responseTime = Date().timeIntervalSince(startTime) * 1000
        record(responseTime: responseTime, forHost: pinger.hostName)
    }

    func timeoutTriggered(_ timer: Timer) {
        guard let host = (timer.userInfo as! [String: Any])["host"] as? String else { return }
        guard let _ = pingerTimeoutTimers[host] else { return }
        print("\(host) timed out")
        self.record(responseTime: 1000, forHost: host)
    }
}
