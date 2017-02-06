//
//  File.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import TooLegit
@testable import FileKit
import SoPersistent

extension File {
    static func template(session: Session) -> File {
        let file = File(inContext: try! session.filesManagedObjectContext())
        file.id = "1"
        file.name = "IMG_1234"
        return file
    }
}
