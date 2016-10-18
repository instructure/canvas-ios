//
//  ManagedFactory.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 10/10/16.
//  Copyright © 2016 instructure. All rights reserved.
//

import CoreData
import TooLegit
import Marshal
import SoPersistent
@testable import FileKit

public typealias FactoryOptions = [String: AnyObject]

public enum ManagedObjectContext {
    case EnrollmentKit, AssignmentKit, FileKit

    public func value(session: Session, options: FactoryOptions = [:]) -> NSManagedObjectContext {
        let scope: String? = try? options <| "scope"

        switch self {
        case .EnrollmentKit:
            return try! session.enrollmentManagedObjectContext(scope)
        case .AssignmentKit:
            return try! session.assignmentsManagedObjectContext(scope)
        case .FileKit:
            return try! session.filesManagedObjectContext()
        }
    }
}

public protocol ManagedFactory {
    static var auto_managedObjectContext: ManagedObjectContext { get }
    static func define(object: Self)
}

extension ManagedFactory where Self: NSManagedObject {
    public static func build(inSession session: Session, options: FactoryOptions = [:], customize: (Self) -> Void = { _ in }) -> Self {
        let context = auto_managedObjectContext.value(session, options: options)
        return build(inContext: context, customize: customize)
    }
    
    public static func build(inContext context: NSManagedObjectContext, customize: (Self) -> Void = { _ in }) -> Self {
        let f: Self = create(inContext: context)
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
    public func managedObjectContext<T: ManagedFactory>(factoryType: T.Type, options: FactoryOptions = [:]) -> NSManagedObjectContext {
        return factoryType.auto_managedObjectContext.value(self)
    }
}
