//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation

enum Edit<T>: CustomDebugStringConvertible {
    case insert(T, Int) // Insert an item at a destination index
    case delete(T, Int) // Delete an item at a source index
    case replace(T, Int) // Replace an item at a destination index
    case move(T, Int, Int) // Move an item from a source index to a destination index

    var debugDescription: String {
        switch self {
        case let .insert(char, index): return "insert \(char) at index \(index)"
        case let .delete(char, index): return "delete \(char) at index \(index)"
        case let .replace(char, index): return "at index \(index) replace with \(char)"
        case let .move(char, fIndex, tIndex): return "move \(char) from index \(fIndex) to \(tIndex)"
        }
    }
}

extension Swift.Collection where Iterator.Element: Equatable {

    /*
     This method uses a variation on the Wagner-Fischer algorithm to compute the edit distance
     https://en.wikipedia.org/wiki/Wagner–Fischer_algorithm

     However, instead of simply storing the edit distance in each position in the matrix, we instead store
     the actual edits required to get to that entry. The edit distance is therefore the number of edits
     at that entry.

     So, by the time the algorithm finishes, the array of edits in the final position will be the
     optimal edits required to transform the receiving collection into the target collection.
     */
    func distanceTo<D: Swift.Collection>(_ other: D) -> Array<Edit<Iterator.Element>> where D.Iterator.Element == Iterator.Element {
        var matrix = Dictionary<XY, Array<Edit<Iterator.Element>>>()
        matrix[XY(-1, -1)] = []

        let from = Array(self)
        let to = Array(other)

        var previousEdits = Array<Edit<Iterator.Element>>()
        for (index, item) in to.enumerated() {
            let theseEdits = previousEdits + [.insert(item, index)]
            matrix[XY(-1, index)] = theseEdits
            previousEdits = theseEdits
        }

        previousEdits = []
        for (index, item) in from.enumerated() {
            let theseEdits = previousEdits + [.delete(item, index)]
            matrix[XY(index, -1)] = theseEdits
            previousEdits = theseEdits
        }

        for (tIndex, tItem) in to.enumerated() {
            for (fIndex, fItem) in from.enumerated() {
                let key = XY(fIndex, tIndex)
                if fItem == tItem {
                    matrix[key] = matrix[XY(fIndex-1, tIndex-1)]!
                } else {
                    let deletions = matrix[XY(fIndex - 1, tIndex)]!
                    let insertions = matrix[XY(fIndex, tIndex - 1)]!
                    let replacings = matrix[XY(fIndex - 1, tIndex - 1)]!

                    let edits: Array<Edit<Iterator.Element>>
                    if deletions.count < insertions.count && deletions.count < replacings.count {
                        // delete!
                        edits = deletions + [.delete(fItem, fIndex)]
                    } else if insertions.count < deletions.count && insertions.count < replacings.count {
                        // insert!
                        edits = insertions + [.insert(tItem, tIndex)]
                    } else {
                        // replace!
                        edits = replacings + [.replace(tItem, tIndex)]
                    }
                    matrix[key] = edits
                }
            }
        }

        let edits = matrix[XY(from.count-1, to.count-1)]!

        // now that we have these edits, we can see if we delete+insert the same item
        var finalEdits = Array<Edit<Iterator.Element>>()
        var handledIndexes = Set<Int>()

        for (index, edit) in edits.enumerated() {
            if handledIndexes.contains(index) { continue }

            var newEdit = edit
            for (otherIndex, otherEdit) in edits.enumerated() {
                if index == otherIndex { continue }
                switch (edit, otherEdit) {
                case let (.insert(item, index), .delete(otherItem, otherItemIndex)) where item == otherItem:
                    newEdit = .move(item, otherItemIndex, index)
                    handledIndexes.insert(otherIndex)
                    break
                case let (.delete(item, index), .insert(otherItem, otherItemIndex)) where item == otherItem:
                    newEdit = .move(item, index, otherItemIndex)
                    handledIndexes.insert(otherIndex)
                    break
                default:
                    break
                }
            }
            finalEdits.append(newEdit)
        }
        return finalEdits
    }
}

private struct XY: Hashable, CustomDebugStringConvertible {
    let a: Int
    let b: Int
    let hashValue: Int
    let debugDescription: String
    init(_ a: Int, _ b: Int) {
        self.a = a
        self.b = b
        hashValue = a.hashValue ^ b.hashValue
        debugDescription = "\(a),\(b)"
    }
}
private func ==(lhs: XY, rhs: XY) -> Bool { return lhs.a == rhs.a && lhs.b == rhs.b }
