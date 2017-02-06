//
//  FileUploadBatch.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/25/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import TooLegit
@testable import FileKit
import SoPersistent

extension FileUploadBatch {
    static func template(session: Session) -> FileUploadBatch {
        let data = Data()
        let uploadable = NewFileUpload(kind: .data(data), data: data)
        return FileUploadBatch(session: session, fileTypes: [], apiPath: "")
    }
}
