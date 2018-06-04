//
//  URL+Core.swift
//  CanvasCore
//
//  Created by Layne Moseley on 5/31/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

public extension URL {
    
    public var allQueryItems: [URLQueryItem] {
        get {
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
            if let allQueryItems = components.queryItems {
                return allQueryItems as [URLQueryItem]
            } else {
                return [URLQueryItem]()
            }
        }
    }
    
    public func queryItemForKey(_ key: String) -> URLQueryItem? {
        let predicate = NSPredicate(format: "name=%@", key)
        return (allQueryItems as NSArray).filtered(using: predicate).first as? URLQueryItem
        
    }
    
    public func appending(value: String, forQueryParameter param: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        var query = components?.queryItems ?? []
        query.append(URLQueryItem(name: param, value: value))
        components?.queryItems = query
        return components?.url
    }
}
