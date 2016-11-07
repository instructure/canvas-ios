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