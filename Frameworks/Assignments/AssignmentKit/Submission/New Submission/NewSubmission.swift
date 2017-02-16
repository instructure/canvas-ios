//
//  OldNewSubmission.swift
//  Assignments
//
//  Created by Nathan Armstrong on 12/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import FileKit

public enum NewSubmission {
    case fileUpload([File])
    case text(String)
    case url(URL)
    case arc(URL)

    var parameters: [String: Any] {
        switch self {
        case .fileUpload(let files):
            return [
                "submission_type": "online_upload",
                "file_ids": files.map { $0.id }
            ]
        case .text(let text):
            return [
                "submission_type": "online_text_entry",
                "body": text
            ]
        case .url(let url):
            return [
                "submission_type": "online_url",
                "url": url.absoluteString
            ]
        case .arc(let url):
            return [
                "submission_type": "basic_lti_launch",
                "url": url.absoluteString
            ]
        }
    }
}
