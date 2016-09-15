//
//  ManagedObjectContextScheduler.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 3/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import ReactiveCocoa
import CoreData

public final class ManagedObjectContextScheduler: SchedulerType {
    let context: NSManagedObjectContext
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func schedule(action: () -> ()) -> Disposable? {
        context.performBlock(action)
        return nil
    }
}
