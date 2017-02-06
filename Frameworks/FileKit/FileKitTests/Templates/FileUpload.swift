//
//  FileUpload.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import TooLegit
@testable import FileKit
import SoPersistent

extension FileUpload {
    static func template(session: Session) -> FileUpload {
        return FileUpload(
            inContext: try! session.filesManagedObjectContext(),
            backgroundSessionID: "1",
            path: "/path",
            data: Data(),
            name: "IMG_1234",
            contentType: nil,
            parentFolderID: nil,
            contextID: ContextID(id: "1", context: .course)
        )
    }
}
