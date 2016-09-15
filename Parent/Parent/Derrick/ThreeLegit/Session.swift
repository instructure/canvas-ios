//
//  Session.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/22/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation



public class Session {
    public let user: User
    public let baseURL: NSURL
    public let masqueradeAsUserID: String?
    public let URLSession: NSURLSession
    
    public init(baseURL: NSURL, user: User, token: String, masqueradeAsUserID: String? = nil) {
        self.user = user
        self.masqueradeAsUserID = masqueradeAsUserID
        self.baseURL = baseURL

        // set up the authorized session with default headers
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        var headers = defaultHTTPHeaders
        headers["Authorization"] =  "Bearer \(token)"
        config.HTTPAdditionalHeaders = headers
        self.URLSession = NSURLSession(configuration: config)
    }
    
    var sessionID: String {
        let masq = masqueradeAsUserID.map { "-\($0)" } ?? ""
        let host = baseURL.host ?? "unknown-host"
        return "\(host)-\(user.id)\(masq)"
    }
    
    public var localStoreDirectoryURL: NSURL {
        guard let lib = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first else { fatalError("GASP! There were no user library search paths") }
        let fileURL = NSURL(fileURLWithPath: lib)
        
        let url = fileURL.URLByAppendingPathComponent(sessionID)
        let _ = try? NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
        return url
    }
}

