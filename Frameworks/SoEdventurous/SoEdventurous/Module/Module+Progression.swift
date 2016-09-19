//
//  Module+Progression.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData

extension Module {
    public func moduleItem(after currentModuleItem: ModuleItem, inContext context: NSManagedObjectContext) -> ModuleItem? {
        // position is 1-based
        var nextItemNumber = currentModuleItem.position + 1
        while nextItemNumber <= itemCount {
            let nextItemPredicate = NSPredicate(format: "%K == %d", "position", nextItemNumber)
            do {
                if let next: ModuleItem = try context.findOne(withPredicate: nextItemPredicate), content = next.content {
                    switch content {
                    case .SubHeader:
                        break // ignore!
                    default:
                        return next
                    }
                } else {
                    return nil
                }
            } catch {
                return nil
            }
            nextItemNumber += 1
        }
        return nil
    }

    public func moduleItem(before currentModuleItem: ModuleItem, inContext context: NSManagedObjectContext) -> ModuleItem? {
        var previousItemNumber = currentModuleItem.position - 1
        while previousItemNumber > 0 {
            let previousItemPredicate = NSPredicate(format: "%K == %d", "position", previousItemNumber)
            do {
                if let previous: ModuleItem = try context.findOne(withPredicate: previousItemPredicate), content = previous.content {
                    switch content {
                    case .SubHeader:
                        break // ignore!
                    default:
                        return previous
                    }
                } else {
                    return nil
                }
            } catch {
                return nil
            }
            previousItemNumber -= 1
        }
        return nil
    }
}