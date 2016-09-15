//
//  AssignmentCassette.swift
//  Assignments
//
//  Created by Nathan Armstrong on 3/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoAutomated

enum AssignmentCassette: String {
    case Detail = "assignment"

    var name: String {
        return self.rawValue
    }
}

enum SubmissionUploadCassette: String {
    case Text = "submit_text"
    case URL = "submit_url"
    case Files = "upload_and_submit_files"

    var name: String {
        return self.rawValue
    }
}
