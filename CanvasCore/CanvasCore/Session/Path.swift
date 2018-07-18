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

