//
//  FileUpload+Details.swift
//  FileKit
//
//  Created by Nathan Armstrong on 2/7/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import TooLegit
import ReactiveSwift
import Result

extension FileUpload {
    public static func observer(session: Session, predicate: NSPredicate) throws -> Signal<FileUpload, NoError> {
        let context = try session.filesManagedObjectContext()
        return NotificationCenter.default.reactive
            .notifications(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
            .mapChanges(matching: predicate)
            .skipNil()
            .map { _, object in object }
            .skipNil()
    }
}
