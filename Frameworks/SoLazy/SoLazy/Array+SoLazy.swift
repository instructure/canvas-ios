//
//  Array+SoLazy.swift
//  SoLazy
//
//  Created by Ben Kraus on 5/15/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation

/// A glorious shuffle method to shuffle all the things
public extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    public func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

public extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    public mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}