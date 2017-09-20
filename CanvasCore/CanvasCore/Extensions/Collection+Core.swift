//
//  Collection+Core.swift
//  CanvasCore
//
//  Created by Layne Moseley on 9/20/17.
//  Copyright © 2017 Instructure, Inc. All rights reserved.
//

import Foundation

public extension Collection {
    public func findFirstMatch(_ test: (Iterator.Element) throws -> Bool) rethrows -> Iterator.Element? {
        for (_, element) in enumerated() {
            if try test(element) {
                return element
            }
        }
        return nil
    }
}
