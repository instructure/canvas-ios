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



public struct ContextID: Hashable, Equatable, CustomStringConvertible {
    
    public static let currentUser = ContextID.user(withID: "self")
    
    public static func course(withID courseID: String) -> ContextID {
        return ContextID(id: courseID, context: .course)
        
    }
    
    public static func group(withID groupID: String) -> ContextID {
        return ContextID(id: groupID, context: .group)
    }
    
    public static func user(withID userID: String) -> ContextID {
        return ContextID(id: userID, context: .user)
    }
    
    public static func account(withID accountID: String) -> ContextID {
        return ContextID(id: accountID, context: .account)
    }
    
    public enum Context: String {
        case course = "course"
        case group = "group"
        case user = "user"
        case account = "account"

        public var pathComponent: String {
            return rawValue + "s"
        }
        
        init?(pathComponent: String) {
            guard let component = Context.allContexts.filter({ $0.pathComponent == pathComponent }).first else {
                return nil
            }
            
            self = component
        }
        
        fileprivate static var allContexts: [Context] = [.course, .group, .user, .account]
    }
    
    public let id: String
    public let context: Context
    
    public init(id: String, context: Context) {
        self.id = id
        self.context = context
    }
    
    /// E.g. course_123, group_333, account_5912
    public var canvasContextID: String {
        return context.rawValue + "_\(id)"
    }
    
    /** The api path for the resources
     
     in the format `api/v1/courses/<id>`
     */
    public var apiPath: String {
        return api/v1/context.pathComponent/id
    }
    
    /** The html path for the resources
     
     in the format `courses/<id>`
     */
    public var htmlPath: String {
        return context.pathComponent/id
    }
    
    public var hashValue: Int {
        return htmlPath.hashValue
    }
    
    public var description: String {
        return canvasContextID
    }
}

public func ==(lhs: ContextID, rhs: ContextID) -> Bool {
    return lhs.htmlPath == rhs.htmlPath
}

// MARK: Parsing

extension ContextID {
    fileprivate static func parseContextAndID(_ path: String) -> (Context, String)? {
        let components = (path as NSString).pathComponents
        
        let matches: [(Int, Context)] = components.enumerated().flatMap { (index, component) in
                return Context(pathComponent: component).map { (index, $0) }
            }
        
        guard let (index, context) = matches.first, (index + 1) < components.count else { return nil }
        
        let id = components[index + 1]
        
        return (context, expandTildaForCrossShardID(id))
    }
    
    public init?(url: URL) {
        guard let (context, id) = ContextID.parseContextAndID(url.path) else { return nil }
        
        self.id = id
        self.context = context
    }
    
    public init?(path: String) {
        guard let (context, id) = ContextID.parseContextAndID(path) else { return nil }
        
        self.id = id
        self.context = context
    }
    
    public init?(canvasContext: String) {
        let components = canvasContext.components(separatedBy: "_")
        guard components.count == 2 else { return nil }
        guard let context = Context(rawValue: components[0].lowercased()) else { return nil }
        self.context = context
        self.id = expandTildaForCrossShardID(components[1])
    }
}


