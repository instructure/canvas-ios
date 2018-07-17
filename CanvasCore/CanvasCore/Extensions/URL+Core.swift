//
// Copyright (C) 2018-present Instructure, Inc.
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
