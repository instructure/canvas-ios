//
//  CollectionType+Edits.swift
//  SoPersistent
//
//  Created by Ben Kraus on 3/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

enum Edit<T>: CustomDebugStringConvertible {
    case Insert(T, Int) // Insert an item at a destination index
    case Delete(T, Int) // Delete an item at a source index
    case Replace(T, Int) // Replace an item at a destination index
    case Move(T, Int, Int) // Move an item from a source index to a destination index

    var debugDescription: String {
        switch self {
        case let .Insert(char, index): return "insert \(char) at index \(index)"
        case let .Delete(char, index): return "delete \(char) at index \(index)"
        case let .Replace(char, index): return "at index \(index) replace with \(char)"
        case let .Move(char, fIndex, tIndex): return "move \(char) from index \(fIndex) to \(tIndex)"
        }
    }
}

extension CollectionType where Generator.Element: Equatable {

    /*
     This method uses a variation on the Wagner-Fischer algorithm to compute the edit distance
     https://en.wikipedia.org/wiki/Wagner–Fischer_algorithm

     However, instead of simply storing the edit distance in each position in the matrix, we instead store
     the actual edits required to get to that entry. The edit distance is therefore the number of edits
     at that entry.

     So, by the time the algorithm finishes, the array of edits in the final position will be the
     optimal edits required to transform the receiving collection into the target collection.
     */
    func distanceTo<D: CollectionType where D.Generator.Element == Generator.Element>(other: D) -> Array<Edit<Generator.Element>> {
        var matrix = Dictionary<XY, Array<Edit<Generator.Element>>>()
        matrix[XY(-1, -1)] = []

        let from = Array(self)
        let to = Array(other)

        var previousEdits = Array<Edit<Generator.Element>>()
        for (index, item) in to.enumerate() {
            let theseEdits = previousEdits + [.Insert(item, index)]
            matrix[XY(-1, index)] = theseEdits
            previousEdits = theseEdits
        }

        previousEdits = []
        for (index, item) in from.enumerate() {
            let theseEdits = previousEdits + [.Delete(item, index)]
            matrix[XY(index, -1)] = theseEdits
            previousEdits = theseEdits
        }

        for (tIndex, tItem) in to.enumerate() {
            for (fIndex, fItem) in from.enumerate() {
                let key = XY(fIndex, tIndex)
                if fItem == tItem {
                    matrix[key] = matrix[XY(fIndex-1, tIndex-1)]!
                } else {
                    let deletions = matrix[XY(fIndex - 1, tIndex)]!
                    let insertions = matrix[XY(fIndex, tIndex - 1)]!
                    let replacings = matrix[XY(fIndex - 1, tIndex - 1)]!

                    let edits: Array<Edit<Generator.Element>>
                    if deletions.count < insertions.count && deletions.count < replacings.count {
                        // delete!
                        edits = deletions + [.Delete(fItem, fIndex)]
                    } else if insertions.count < deletions.count && insertions.count < replacings.count {
                        // insert!
                        edits = insertions + [.Insert(tItem, tIndex)]
                    } else {
                        // replace!
                        edits = replacings + [.Replace(tItem, tIndex)]
                    }
                    matrix[key] = edits
                }
            }
        }

        let edits = matrix[XY(from.count-1, to.count-1)]!

        // now that we have these edits, we can see if we delete+insert the same item
        var finalEdits = Array<Edit<Generator.Element>>()
        var handledIndexes = Set<Int>()

        for (index, edit) in edits.enumerate() {
            if handledIndexes.contains(index) { continue }

            var newEdit = edit
            for (otherIndex, otherEdit) in edits.enumerate() {
                if index == otherIndex { continue }
                switch (edit, otherEdit) {
                case let (.Insert(item, index), .Delete(otherItem, otherItemIndex)) where item == otherItem:
                    newEdit = .Move(item, otherItemIndex, index)
                    handledIndexes.insert(otherIndex)
                    break
                case let (.Delete(item, index), .Insert(otherItem, otherItemIndex)) where item == otherItem:
                    newEdit = .Move(item, index, otherItemIndex)
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