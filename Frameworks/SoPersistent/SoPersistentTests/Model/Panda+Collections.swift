//
//  Panda+Collections.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent
import TooLegit
import CoreData

extension Panda {
    static func collectionByFirstLetterOfName(session: Session, inContext context: NSManagedObjectContext) throws -> FetchedCollection<Panda> {
        let frc = Panda.fetchedResults(nil, sortDescriptors: ["name".ascending], sectionNameKeypath: "firstLetterOfName", inContext: context)
        let titleFunction: String?->String? = { $0.flatMap { "\($0.uppercaseString)" } }
        return try FetchedCollection<Panda>(frc: frc, titleForSectionTitle:titleFunction)
    }

    static func collection(session: Session, inContext context: NSManagedObjectContext) throws -> FetchedCollection<Panda> {
        let frc = Panda.fetchedResults(nil, sortDescriptors: ["name".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection<Panda>(frc: frc)
    }

    static func pandasNamedPo(session: Session, inContext context: NSManagedObjectContext) throws -> FetchedCollection<Panda> {
        let predicate = NSPredicate(format: "%K == %@", "name", "Po")
        let frc = Panda.fetchedResults(predicate, sortDescriptors: ["id".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }
}
