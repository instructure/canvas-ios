//
//  Path.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 6/29/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

public typealias Path = String

public protocol PathComponent {
    var pathComponent: String { get }
}

public func /<T: PathComponent>(path: Path, @autoclosure component: ()->T) -> Path {
    return (path as NSString).stringByAppendingPathComponent(component().pathComponent)
}

public func /<T: PathComponent>(url: NSURL, @autoclosure component: ()->T) -> NSURL {
    return url.URLByAppendingPathComponent(component().pathComponent)
}

extension String : PathComponent {
    public var pathComponent: String {
        return self
    }
}

extension IntegerType {
    public var pathComponent: String {
        return "\(self)"
    }
}

extension Int: PathComponent {}
extension Int64: PathComponent {}

public let api: Path  = "api"
public let v1: String = "v1"

