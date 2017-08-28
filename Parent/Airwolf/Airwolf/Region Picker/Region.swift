//
//  Region.swift
//  Airwolf
//
//  Created by Derrick Hathaway on 8/21/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import Foundation

public struct Region: Hashable {
    public let name: String
    public let url: URL
    public let isBeta: Bool
    
    private init(name: String, url: URL, isBeta: Bool = false) {
        self.name = name
        self.url = url
        self.isBeta = isBeta
    }
    
    public var hashValue: Int {
        return url.hashValue
    }
    
    static var pickedRegion: Region? {
        set {
            if let new = newValue, new.isBeta { return } // don't overwrite picked region
            UserDefaults.standard.set(newValue?.url, forKey: "picked-region")
        }
        get {
            let savedRegionURL = UserDefaults.standard.url(forKey: "picked-region")
            return Region
                .productionRegions
                .first { $0.url.host! == savedRegionURL?.host }
        }
    }
    
    public static let beta = Region(
        name: "Beta",
        url: URL(string: "https://airwolf-iad-gamma.inscloudgate.net/")!
    )
    
    static let us = Region(
        name: NSLocalizedString("United States", comment: ""),
        url: URL(string: "https://airwolf-iad-prod.instructure.com")!
    )
    static let australia = Region(
        name: NSLocalizedString("Australia", comment: ""),
        url: URL(string: "https://airwolf-syd-prod.instructure.com")!
    )
    static let canada = Region(
        name: NSLocalizedString("Canada", comment: ""),
        url: URL(string: "https://airwolf-yul-prod.instructure.com")!
    )
    static let germany = Region(
        name: NSLocalizedString("Germany", comment: ""),
        url: URL(string: "https://airwolf-fra-prod.instructure.com")!
    )
    static let ireland = Region(
        name: NSLocalizedString("Ireland", comment: ""),
        url: URL(string: "https://airwolf-dub-prod.instructure.com")!
    )
    static let singapore = Region(
        name: NSLocalizedString("Singapore", comment: ""),
        url: URL(string: "https://airwolf-sin-prod.instructure.com")!
    )
    
    public static let `default`: Region = .us
    
    public static let productionRegions: [Region] = [
        .australia,
        .canada,
        .germany,
        .ireland,
        .singapore,
        .us,
    ]
    
    private static let regionsByAirwolfID: [String: Region] = [
        "ca-central-1":     .canada,
        "eu-central-1":     .germany,
        "eu-west-1":        .ireland,
        "ap-southeast-1":   .singapore,
        "ap-southeast-2":   .australia,
        "us-east-1":        .us,
    ]
    public static func region(forAirwolfRegionID regionID: String) -> Region? {
        return regionsByAirwolfID[regionID]
    }
    public static func region(for url: URL) -> Region {
        let matchingRegion = Region.productionRegions.first { prodRegion in
            guard let host = prodRegion.url.host else { return false }
            return host == url.host
        }
        
        return matchingRegion ?? .default
    }
}

public func ==(lhs: Region, rhs: Region) -> Bool {
    return lhs.url == rhs.url
}

