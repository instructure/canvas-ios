//
//  RegionPicker.swift
//  Airwolf
//
//  Created by Ben Kraus on 8/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SystemConfiguration

private let regions = [
    "airwolf-iad-prod.instructure.com",
    "airwolf-dub-prod.instructure.com",
    "airwolf-syd-prod.instructure.com",
    "airwolf-sin-prod.instructure.com"
]

private let pickedRegionKey = "picked-region"

public class RegionPicker: NSObject {

    public static let defaultPicker = RegionPicker()

    private (set) internal var completion: (NSURL?)->Void = { _ in }

    private var pingers: [String: SimplePing] = [:]

    private var responseTimes: [String: [Double]] = [:]
    private var averageResponseTimes: [String: Double] = [:]
    private var pingStartTimes: [String: NSDate] = [:]
    private var pingerTimeoutTimers: [String: NSTimer] = [:]

    override public init() {
        super.init()

        for region in regions {
            let pinger = SimplePing(hostName: region)
            pinger.delegate = self
            pingers[region] = pinger

            responseTimes[region] = []
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

    public func setRegionToDefault() {
        let url = NSURL(string: "https://\(regions[0])")!
        NSUserDefaults.standardUserDefaults().setURL(url, forKey: pickedRegionKey)
    }

    public func pickedRegion() -> NSURL? {
        return NSUserDefaults.standardUserDefaults().URLForKey(pickedRegionKey)
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

            if averageResponseTimes.keys.count == regions.count {
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

                NSUserDefaults.standardUserDefaults().setURL(url, forKey: pickedRegionKey)
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