//
//  PathTemplate.swift
//  SoPathetic
//
//  Created by Derrick Hathaway on 7/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation


public struct PathTemplate<P> {
    public let match: (String)->P?
    
    public init(_ m: @escaping (String)->P?) {
        match = m
    }
    
    func slash<C, R>(_ child: PathTemplate<C>, aggregate: @escaping (P, C)->R) -> PathTemplate<R> {
        return PathTemplate<R> { path in
            guard let c = child.match((path as NSString).lastPathComponent) else {
                return nil
            }
            
            guard let p = self.match((path as NSString).deletingLastPathComponent) else {
                return nil
            }
            
            return aggregate(p, c)
        }
    }
    
    public func map<U>(transform: @escaping (P)->U?) -> PathTemplate<U> {
        return PathTemplate<U>({ path in
            return self.match(path).flatMap(transform)
        })
    }
}

public let root = PathTemplate<()> { path in
    if path == "/" {
        return ()
    }
    return nil
}

func optional(_ template: PathTemplate<()>) -> PathTemplate<()> {
    return PathTemplate { path in
        if path == "" || path == "/" {
            return ()
        }
        
        return template.match(path)
    }
}

func literalComponent(_ literal: String) -> PathTemplate<()> {
    return PathTemplate<()> { path in
        if path == literal {
            return ()
        }
        return nil
    }
}


prefix operator /

public prefix func /(rhs: CustomStringConvertible) -> PathTemplate<()> {
    return root.slash(literalComponent(rhs.description), aggregate: +)
}

public prefix func /<P>(rhs: @escaping (String)->P?) -> PathTemplate<P> {
    return root.slash(PathTemplate(rhs), aggregate: +)
}

public func /(lhs: PathTemplate<()>, rhs: CustomStringConvertible) -> PathTemplate<()> {
    return lhs.slash(literalComponent(rhs.description), aggregate: +)
}

public func /<R>(lhs: PathTemplate<()>, rhs: @escaping (String)->R?) -> PathTemplate<R> {
    return lhs.slash(PathTemplate(rhs), aggregate: +)
}

public func /<A>(lhs: PathTemplate<A>, rhs: CustomStringConvertible) -> PathTemplate<A> {
    return lhs.slash(literalComponent(rhs.description), aggregate: +)
}

public func /<A, B>(lhs: PathTemplate<A>, rhs: @escaping (String)->B?) -> PathTemplate<(A,B)> {
    return lhs.slash(PathTemplate(rhs), aggregate: +)
}

public func /<A, B, C>(lhs: PathTemplate<(A, B)>, rhs: @escaping (String)->C?) -> PathTemplate<(A, B, C)> {
    return lhs.slash(PathTemplate(rhs), aggregate: +)
}

public func /<A, B, C, D>(lhs: PathTemplate<(A, B, C)>, rhs: @escaping (String)->D?) -> PathTemplate<(A, B, C, D)> {
    return lhs.slash(PathTemplate(rhs), aggregate: +)
}

public func /<A, B, C, D, E>(lhs: PathTemplate<(A, B, C, D)>, rhs: @escaping (String)->E?) -> PathTemplate<(A, B, C, D, E)> {
    return lhs.slash(PathTemplate(rhs), aggregate: +)
}

public func /<A, B, C, D, E, F>(lhs: PathTemplate<(A, B, C, D, E)>, rhs: @escaping (String)->F?) -> PathTemplate<(A, B, C, D, E, F)> {
    return lhs.slash(PathTemplate(rhs), aggregate: +)
}



prefix operator /?

public prefix func /?(rhs: CustomStringConvertible) -> PathTemplate<()> {
    return optional(root).slash(literalComponent(rhs.description), aggregate: +)
}

public prefix func /?<P>(rhs: @escaping (String)->P?) -> PathTemplate<P> {
    return optional(root).slash(PathTemplate(rhs), aggregate: +)
}

infix operator /? : MultiplicationPrecedence

public func /?(lhs: PathTemplate<()>, rhs: CustomStringConvertible) -> PathTemplate<()> {
    return optional(lhs).slash(literalComponent(rhs.description), aggregate: +)
}

public func /?<P>(lhs: PathTemplate<()>, rhs: @escaping (String)->P?) -> PathTemplate<P> {
    return optional(lhs).slash(PathTemplate(rhs), aggregate: +)
}

public let integer: (String)->Int? = {Int($0)}
public let double: (String)->Double? = {Double($0)}
public let string: (String)->String? = {$0}




