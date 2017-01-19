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
import ReactiveSwift
import Result
import MobileCoreServices
import FileKit

let itemError = NSError(subdomain: "AssignmentKit.Submissions", description: NSLocalizedString("Failed to load item. Check the allowed assignment submission types.", comment: "Error message when submission attachment fails to load."))

public protocol Attachment {
    func conforms(toUTI uti: String) -> Bool
    func load(uti: String, completion: @escaping (Result<Any, NSError>) -> Void)
}

extension Assignment {
    public func submissions(for attachments: [Attachment], callback: @escaping (Result<[NewUpload], NSError>) -> Void) {
        var attachments: [Attachment] = attachments.reversed()
        var submissions: [NewUpload] = []
        var files: [NewUploadFile] = []

        func load(_ attachments: [Attachment]) {
            var attachments = attachments
            guard let attachment = attachments.popLast() else {
                if !files.isEmpty {
                    submissions.append(.fileUpload(files))
                }
                callback(Result(submissions))
                return
            }

            guard let uti = self.allowedSubmissionUTIs.index(where: attachment.conforms).flatMap({ self.allowedSubmissionUTIs[$0] }) else {
                callback(Result(error: itemError))
                return
            }

            attachment.load(uti: uti) { result in
                guard let item = result.value, let upload = NewUpload.from(uti, item: item) else {
                    callback(Result(error: result.error ?? itemError))
                    return
                }

                switch upload {
                case let .fileUpload(f):
                    files += f
                case let .mediaComment(f):
                    files.append(f)
                case .text, .url:
                    submissions.append(upload)
                case .none:
                    callback(Result(error: itemError))
                    return
                }

                load(attachments)
            }
        }

        load(attachments)
    }
}
