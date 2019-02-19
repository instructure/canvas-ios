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

/// A glorious shuffle method to shuffle all the things
public extension Swift.Collection {
    /// Return a copy of `self` with its elements shuffled
    public func shuffle() -> [Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

public extension Swift.Collection {
    public func findFirst(_ test: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
        for (_, element) in enumerated() {
            if try test(element) {
                return element
            }
        }
        return nil
    }
    
    public func any(_ test: ((Iterator.Element) throws -> Bool)) rethrows -> Bool {
        return try findFirst(test) != nil
    }
    
    public func any() -> Bool {
        return any { _ in true }
    }
    
    public func all(_ test: ((Iterator.Element) throws -> Bool)) rethrows -> Bool {
        return try filter { !(try test($0)) }.isEmpty
    }
}


public extension Array {
    /// Shuffle the elements of `self` in-place.
    public mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            let itemAtI = self[i]
            self[i] = self[j]
            self[j] = itemAtI
        }
    }
}
