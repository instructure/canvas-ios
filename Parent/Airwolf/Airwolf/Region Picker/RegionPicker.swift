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

// if betaURL is set, then the app will only use that url
private let betaURL: NSURL? =
    nil
//    NSURL(string: "https://airwolf-iad-gamma.inscloudgate.net/")

public class RegionPicker: NSObject {
    
    // the only region used is beta when `betaURL` is set
    static let regions = betaURL.map { [$0] } ?? [
        NSURL(string: "https://airwolf-iad-prod.instructure.com")!,
        NSURL(string: "https://airwolf-dub-prod.instructure.com")!,
        NSURL(string: "https://airwolf-syd-prod.instructure.com")!,
        NSURL(string: "https://airwolf-sin-prod.instructure.com")!,
        NSURL(string: "https://airwolf-fra-prod.instructure.com")!
    ]
    

    public static let defaultPicker = RegionPicker()

    private (set) internal var completion: (NSURL?)->Void = { _ in }

    private var pingers: [String: SimplePing] = [:]

    private var responseTimes: [String: [Double]] = [:]
    private var averageResponseTimes: [String: Double] = [:]
    private var pingStartTimes: [String: NSDate] = [:]
    private var pingerTimeoutTimers: [String: NSTimer] = [:]

    override public init() {
        super.init()

        for region in RegionPicker.regions {
            let pinger = SimplePing(hostName: region.host!)
            pinger.delegate = self
            pingers[region.host!] = pinger

            responseTimes[region.host!] = []
        }
    }

    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    internal(set) public var pickedRegionURL: NSURL? {
        set {
            if betaURL != nil { return } // don't alter the picked region when using beta
            NSUserDefaults.standardUserDefaults().setURL(newValue, forKey: "picked-region")
        } get {
            if let beta = betaURL { return betaURL } // only ever use beta when its turned on
            return NSUserDefaults.standardUserDefaults().URLForKey("picked-region")
        }
    }

    public func setRegionToDefault() {
        pickedRegionURL = RegionPicker.regions[0]
    }

    public func pickBestRegion(completion: (NSURL?)->Void) {
        self.completion = completion
        if isConnectedToNetwork() {
            for (_, pinger) in pingers.enumerate() {
                // Stop it if it's going and restart it
                pinger.1.stop()
                pinger.1.start()
            }
        } else {
            completion(nil)
        }
    }

    private func record(responseTime responseTime: Double, forHost host: String) {
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
            let average = (hostResponseTimes as NSArray).valueForKeyPath("@avg.self") as! NSNumber
            averageResponseTimes[host] = average.doubleValue

            print("5 or more recorded response times for host: \(host) with average of: \(average)")

            if averageResponseTimes.keys.count == RegionPicker.regions.count {
                // We have averages for each - time to make a decision!
                for (_, pinger) in pingers.enumerate() {
                    // Stop it if it's going
                    pinger.1.stop()

                }

                for (host, timer) in pingerTimeoutTimers {
                    timer.invalidate()
                }
                pingerTimeoutTimers.removeAll()

                let smallestResponseTime = ((averageResponseTimes as NSDictionary).allValues as NSArray).valueForKeyPath("@min.self") as! NSNumber
                let key = (averageResponseTimes as NSDictionary).allKeysForObject(smallestResponseTime.doubleValue).first! as! String

                let url = NSURL(string: "https://\(key)")!
                print("\(url) region picked with lowest latency: \(smallestResponseTime)")

                pickedRegionURL = url
                completion(url)
            }
        } else {
            // If we don't have 3 yet, send another
            pingers[host]?.sendPingWithData(nil)
        }
    }
}

extension RegionPicker: SimplePingDelegate {
    public func simplePing(pinger: SimplePing, didStartWithAddress address: NSData) {
        // Start the ping immediately
        pinger.sendPingWithData(nil)
    }

    public func simplePing(pinger: SimplePing, didSendPacket packet: NSData, sequenceNumber: UInt16) {
        pingStartTimes[pinger.hostName] = NSDate()
        pingerTimeoutTimers[pinger.hostName] = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(timeoutTriggered(_:)), userInfo: ["host": pinger.hostName], repeats: false)
    }

    public func simplePing(pinger: SimplePing, didFailWithError error: NSError) {
        record(responseTime: 1000, forHost: pinger.hostName)
    }

    public func simplePing(pinger: SimplePing, didFailToSendPacket packet: NSData, sequenceNumber: UInt16, error: NSError) {
        record(responseTime: 1000, forHost: pinger.hostName)
    }

    public func simplePing(pinger: SimplePing, didReceivePingResponsePacket packet: NSData, sequenceNumber: UInt16) {
        guard let startTime = pingStartTimes[pinger.hostName] else { return }
        let responseTime = NSDate().timeIntervalSinceDate(startTime) * 1000
        record(responseTime: responseTime, forHost: pinger.hostName)
    }

    func timeoutTriggered(timer: NSTimer) {
        guard let host = (timer.userInfo as! [String: AnyObject])["host"] as? String else { return }
        guard let _ = pingerTimeoutTimers[host] else { return }
        print("\(host) timed out")
        self.record(responseTime: 1000, forHost: host)
    }
}
