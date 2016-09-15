//
//  ContextID.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 2/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import SoLazy


public struct ContextID: Hashable, Equatable, CustomStringConvertible {
    public enum Context: String {
        case Course = "course"
        case Group = "group"
        case User = "user"
        case Account = "account"

        public var pathComponent: String {
            return rawValue + "s"
        }
        
        init?(pathComponent: String) {
            guard let component = Context.allContexts.filter({ $0.pathComponent == pathComponent }).first else {
                return nil
            }
            
            self = component
        }
        
        private static var allContexts: [Context] = [.Course, .Group, .User, .Account]
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
    private static func parseContextAndID(path: String) -> (Context, String)? {
        let components = (path as NSString).pathComponents
        
        let matches: [(Int, Context)] = components.enumerate().flatMap { (index, component) in
                return Context(pathComponent: component).map { (index, $0) }
            }
        
        guard let (index, context) = matches.first where (index + 1) < components.count else { return nil }
        
        let id = components[index + 1]
        
        return (context, expandTildaForCrossShardID(id))
    }
    
    public init?(url: NSURL) {
        guard let (context, id) = url.path.flatMap(ContextID.parseContextAndID) else { return nil }
        
        self.id = id
        self.context = context
    }
    
    public init?(path: String) {
        guard let (context, id) = ContextID.parseContextAndID(path) else { return nil }
        
        self.id = id
        self.context = context
    }
    
    public init?(canvasContext: String) {
        let components = canvasContext.componentsSeparatedByString("_")
        guard components.count == 2 else { return nil }
        guard let context = Context(rawValue: components[0].lowercaseString) else { return nil }
        self.context = context
        self.id = expandTildaForCrossShardID(components[1])
    }
}


