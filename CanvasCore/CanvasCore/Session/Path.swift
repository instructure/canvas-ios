//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation

public typealias Path = String

public protocol PathComponent {
    var pathComponent: String { get }
}

public func /<T: PathComponent>(path: Path, component: @autoclosure ()->T) -> Path {
    return (path as NSString).appendingPathComponent(component().pathComponent)
}

public func /<T: PathComponent>(url: URL, component: @autoclosure ()->T) -> URL {
    return url.appendingPathComponent(component().pathComponent)
}

public extension URL {
    func appending(_ queryItem: URLQueryItem) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        var query = components?.queryItems ?? []
        query.append(queryItem)
        components?.queryItems = query
        return components?.url
    }
}

extension String : PathComponent {
    public var pathComponent: String {
        return self
    }
}

extension Integer {
    public var pathComponent: String {
        return "\(self)"
    }
}

extension Int: PathComponent {}
extension Int64: PathComponent {}

public let api: Path  = "api"
public let v1: String = "v1"

