//
//  BeShapedLike.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 7/22/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import Nimble

public func beShapedLike(expected: JSONShape) -> NonNilMatcherFunc<[String: AnyObject]> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "beShapedLike shape"
        guard let actualValue = try actualExpression.evaluate() else {
            return false
        }
        let (matches, key) = jsonShape(expected, matchesObject: actualValue)
        if !matches {
            failureMessage.postfixMessage = "find key \(key)"
        }
        return matches
    }
}

public func beShapedLike(expected: JSONShape) -> NonNilMatcherFunc<[[String: AnyObject]]> {
    return NonNilMatcherFunc { actualExpression, failureMessage in
        failureMessage.postfixMessage = "beShapedLike shape"
        guard let actualValue = try actualExpression.evaluate() else {
            return false
        }
        let (matches, key) = jsonShape(expected, matchesObject: actualValue)
        if !matches {
            failureMessage.postfixMessage = "find key \(key)"
        }
        return matches
    }
}
