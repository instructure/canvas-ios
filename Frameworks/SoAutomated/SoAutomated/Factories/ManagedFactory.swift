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
    
    

import CoreData
import TooLegit
import Marshal
import SoPersistent
@testable import FileKit
@testable import SuchActivity

public typealias FactoryOptions = [String: Any]

public enum ManagedObjectContext {
    case enrollmentKit, assignmentKit, fileKit, soEdventurous, suchActivity

    public func value(_ session: Session, options: FactoryOptions = [:]) -> NSManagedObjectContext {
        let scope: String? = try? options <| "scope"

        switch self {
        case .enrollmentKit:
            return try! session.enrollmentManagedObjectContext(scope)
        case .assignmentKit:
            return try! session.assignmentsManagedObjectContext(scope)
        case .fileKit:
            return try! session.filesManagedObjectContext()
        case .soEdventurous:
            return try! session.soEdventurousManagedObjectContext()
        case .suchActivity:
            return session.suchActivityManagedObjectContext
        }
    }
}

public protocol ManagedFactory {
    static var auto_managedObjectContext: ManagedObjectContext { get }
    static func define(_ object: Self)
}

extension LockableModel {
    func defineLockedStatus() {
        lockedForUser = false
        canView = true
        lockExplanation = nil
    }
}

extension ManagedFactory where Self: NSManagedObject {
    @discardableResult
    public static func build(inSession session: Session, options: FactoryOptions = [:], customize: (Self) -> Void = { _ in }) -> Self {
        let context = auto_managedObjectContext.value(session, options: options)
        return build(inContext: context, customize: customize)
    }
    
    @discardableResult
    public static func build(inContext context: NSManagedObjectContext, customize: (Self) -> Void = { _ in }) -> Self {
        let f: Self = create(inContext: context)
        if let lockable = f as? LockableModel {
            lockable.defineLockedStatus()
        }
        define(f)
        customize(f)
        try! context.saveFRD()
        return f
    }

    public static func observeCount(inSession session: Session, options: FactoryOptions = [:]) -> ManagedObjectCountObserver<Self> {
        let context = auto_managedObjectContext.value(session, options: options)
        return ManagedObjectCountObserver(predicate: NSPredicate(value: true), inContext: context, objectCountUpdated: { _ in })
    }
}

extension Session {
    public func managedObjectContext<T: ManagedFactory>(_ factoryType: T.Type, options: FactoryOptions = [:]) -> NSManagedObjectContext {
        return factoryType.auto_managedObjectContext.value(self)
    }
}
