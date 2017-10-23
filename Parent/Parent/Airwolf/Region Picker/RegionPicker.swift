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

public class RegionPicker: NSObject {
    public static let shared = RegionPicker()
    public let isBeta = MutableProperty<Bool>(false)

    private (set) internal var completion: (URL?)->Void = { _ in }

    private var pingers: [RegionPinger] = []
    private var regionLatencies: [Region: TimeInterval] = [:]

    override public init() {
        super.init()
        
        // Don't ping prod when we're testing the UI.
        guard NSClassFromString("EarlGreyImpl") == nil else {
            completion(nil)
            return
        }
        
        pingers = Region
            .productionRegions
            .map { region in
                return RegionPinger(region: region) { [weak self] region, latency in
                    self?.record(latency: latency, for: region)
            }
        }
    }
    
    public var pickedRegion: Region? {
        set {
            print("Picking Region: \(newValue?.name ?? "nil")")
            if isBeta.value { return } // don't alter the picked region when using beta
            Region.pickedRegion = newValue
        } get {
            if isBeta.value { return .beta } // only ever use beta when its turned on
            return Region.pickedRegion
        }
    }
    
    public var defaultURL: URL {
        return Region.default.url
    }
    
    var betaURL: URL {
        return Region.beta.url
    }
    
    var apiURL: URL {
        return pickedRegion?.url ?? Region.default.url
    }
    
    var isConnectedToNetwork: Bool {
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
    
    public func pickRegion(for url: URL) {
        let newRegion = Region.region(for: url)
        isBeta.value = newRegion.isBeta
        pickedRegion = newRegion
    }

    open func pickBestRegion(_ completion: @escaping (URL?)->Void = {_ in }) {
        
        print("[re]starting pingers")
        self.completion = completion
        if isConnectedToNetwork {
            for pinger in pingers {
                pinger.stop()
                pinger.start()
            }
        } else {
            completion(nil)
        }
    }

    fileprivate func record(latency: TimeInterval, for region: Region) {
        // it is a race after all... first one finished wins!
        pingers.forEach { $0.stop() }
        
        pickedRegion = region
        completion(region.url)
    }
}
