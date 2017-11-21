//
//  URL+SoLazy.swift
//  CanvasCore
//
//  Created by Derrick Hathaway on 11/8/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

extension URL {
    public func appending(value: String, forQueryParameter param: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        var query = components?.queryItems ?? []
        query.append(URLQueryItem(name: param, value: value))
        components?.queryItems = query
        return components?.url
    }
}
