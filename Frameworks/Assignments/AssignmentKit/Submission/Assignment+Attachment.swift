//
//  Assignment+Attachment.swift
//  Assignments
//
//  Created by Nathan Armstrong on 3/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result
import MobileCoreServices
import FileKit

let itemError = NSError(subdomain: "AssignmentKit.Submissions", description: NSLocalizedString("Failed to load item. Check the allowed assignment submission types.", comment: "Error message when submission attachment fails to load."))

public protocol Attachment {
    func conforms(to uti: String) -> Bool
    func load(uti: String, completion: (Result<AnyObject, NSError>) -> Void)
}

extension Assignment {
    public func submissions(for attachments: [Attachment], callback: (Result<[NewUpload], NSError>) -> Void) {
        var attachments: [Attachment] = attachments.reverse()
        var submissions: [NewUpload] = []
        var files: [NewUploadFile] = []

        func load(attachments: [Attachment]) {
            var attachments = attachments
            guard let attachment = attachments.popLast() else {
                if !files.isEmpty {
                    submissions.append(.FileUpload(files))
                }
                callback(Result(submissions))
                return
            }

            guard let uti = self.allowedSubmissionUTIs.indexOf(attachment.conforms).flatMap({ self.allowedSubmissionUTIs[$0] }) else {
                callback(Result(error: itemError))
                return
            }

            attachment.load(uti) { result in
                guard let item = result.value, upload = NewUpload.from(uti, item: item) else {
                    callback(Result(error: result.error ?? itemError))
                    return
                }

                switch upload {
                case let .FileUpload(f):
                    files += f
                case let .MediaComment(f):
                    files.append(f)
                case .Text, .URL:
                    submissions.append(upload)
                case .None:
                    callback(Result(error: itemError))
                    return
                }

                load(attachments)
            }
        }

        load(attachments)
    }
}
