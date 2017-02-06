//
//  Assignment+Attachment.swift
//  Assignments
//
//  Created by Nathan Armstrong on 1/24/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
    public func submissions(for attachments: [Attachment], callback: @escaping (Result<[OldNewSubmission], NSError>) -> Void) {
        var attachments: [Attachment] = attachments.reversed()
        var submissions: [OldNewSubmission] = []
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
                guard let item = result.value, let upload = OldNewSubmission.from(uti, item: item) else {
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

extension OldNewSubmission {
    static func from(_ uti: String, item: Any) -> OldNewSubmission? {
        switch uti {
        case String(kUTTypeText):
            if let text = item as? String {
                return .text(text)
            }
        case String(kUTTypeFileURL), String(kUTTypeURL):
            if let url = item as? URL {
                if url.isFileURL {
                    return .fileUpload([.fileURL(url)])
                }
                return .url(url)
            }
        case String(kUTTypeImage):
            if let image = item as? UIImage {
                return .fileUpload([.photo(image)])
            }
        case String(kUTTypeMovie), String(kUTTypeAudio):
            if let data = item as? Data {
                return .fileUpload([.data(data)])
            }
        case String(kUTTypeItem):
            return from(String(kUTTypeText), item: item) ??
                from(String(kUTTypeFileURL), item: item) ??
                from(String(kUTTypeURL), item: item) ??
                from(String(kUTTypeImage), item: item) ??
                from(String(kUTTypeMovie), item: item) ??
                from(String(kUTTypeAudio), item: item) ??
                (item as? Data).flatMap({ OldNewSubmission.fileUpload([NewUploadFile.data($0)]) })
        default: break
        }

        return nil
    }
}
