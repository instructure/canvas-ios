//
//  Append.swift
//  SoPathetic
//
//  Created by Derrick Hathaway on 7/15/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation


// MARK: ()
/// () + () = ()
func +(zero: (), zilch: ()) -> () {
    return ()
}

/// A + () = A
func +<A>(a: A, naught: ()) -> A {
    return a
}


/// () + A = A
func +<A>(naught: (), a: A) -> A {
    return a
}



// MARK: N + 1 = (N+1)

/// A + B = (A, B)
func +<A, B>(a: A, b: B) -> (A, B) {
    return (a, b)
}

/// (A, B) + C = (A, B, C)
func +<A, B, C>(ab: (A, B), c: C) -> (A, B, C) {
    return (ab.0, ab.1, c)
}

/// (A, B, C) + D = (A, B, C, D)
func +<A, B, C, D>(abc: (A, B, C), d: D) -> (A, B, C, D) {
    return (abc.0, abc.1, abc.2, d)
}

/// (A, B, C, D) + E = (A, B, C, D, E)
func +<A, B, C, D, E>(abcd: (A, B, C, D), e: E) -> (A, B, C, D, E) {
    return (abcd.0, abcd.1, abcd.2, abcd.3, e)
}

/// (A, B, C, D, E) + F = (A, B, C, D, E, F)
func +<A, B, C, D, E, F>(abcde: (A, B, C, D, E), f: F) -> (A, B, C, D, E, F) {
    return (abcde.0, abcde.1, abcde.2, abcde.3, abcde.4, f)
}


