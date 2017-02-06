//
//  SubmissionType.swift
//  Assignments
//
//  Created by Nathan Armstrong on 1/23/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

public enum SubmissionType {
    case text
    case url
    case fileUpload

    var title: String {
        switch self {
        case .text:
            return NSLocalizedString("Enter Text",
                                     tableName: "Localizable",
                                     bundle: .assignments(),
                                     value: "",
                                     comment: "Text submission option")
        case .url:
            return NSLocalizedString("Add Website Address",
                                     tableName: "Localizable",
                                     bundle: .assignments(),
                                     value: "",
                                     comment: "URL submission option")
        case .fileUpload:
            return NSLocalizedString("Upload File",
                                     tableName: "Localizable",
                                     bundle: .assignments(),
                                     value: "",
                                     comment: "File upload submission option")
        }
    }
}
