//
//  Tuple+SoLazy.swift
//  SoLazy
//
//  Created by Nathan Armstrong on 1/26/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

public func blend<A,B,C>(tuple: (A,B), other: C) -> (A,B,C) {
    return (tuple.0, tuple.1, other)
}

public func blend<A,B,C>(other: A, tuple: (B,C)) -> (A,B,C) {
    return (other, tuple.0, tuple.1)
}

public func blend<A,B,C,D>(tuple: (A,B,C), other: D) -> (A,B,C,D) {
    return (tuple.0, tuple.1, tuple.2, other)
}

public func blend<A,B,C,D>(other: A, tuple: (B,C,D)) -> (A,B,C,D) {
    return (other, tuple.0, tuple.1, tuple.2)
}
