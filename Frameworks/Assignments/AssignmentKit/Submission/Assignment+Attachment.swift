//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
