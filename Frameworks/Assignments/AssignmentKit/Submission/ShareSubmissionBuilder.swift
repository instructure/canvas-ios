//
//  ShareSubmissionBuilder.swift
//  Assignments
//
//  Created by Nathan Armstrong on 3/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import ReactiveCocoa
import MobileCoreServices
import FileKit

public struct ShareSubmissionBuilder {
    let assignment: Assignment

    public init(assignment: Assignment) {
        self.assignment = assignment
    }

    public func submissionsForExtensionContext(context: SubmissionExtensionContext) -> SignalProducer<NewUpload, NSError> {
        return SignalProducer(values: context.submissionInputItems)
            .flatMap(.Concat, transform: submissionsForExtensionItem)
            .filter { !$0.isNone }
    }

    func submissionsForExtensionItem(extensionItem: SubmissionExtensionItem) -> SignalProducer<NewUpload, NSError> {
        let attachments = SignalProducer(values: extensionItem.submissionAttachments)
            .flatMap(.Concat, transform: submissionsForAttachment)

        // get all the standalone submissions (Text, URL, etc)
        let submissions = attachments.filter({ !$0.isFileUpload })

        // group the files into a single submission
        let files = attachments.filter({ $0.isFileUpload })
            .reduce([]) { $0 + $1.files }
            .filter { !$0.isEmpty }
            .map { NewUpload.FileUpload($0) }

        return submissions.concat(files)
    }

    func submissionsForAttachment(attachment: Attachment) -> SignalProducer<NewUpload, NSError> {
        return SignalProducer(values: assignment.allowedSubmissionUTIs)
            .filter(attachment.hasItemConformingToTypeIdentifier)
            .flatMap(.Concat, transform: attachment.loadItem)
            .filter { !$0.isNone }
            .take(1)
    }
}

// MARK: - Types

public typealias Attachment = NSItemProvider

@objc
public protocol SubmissionExtensionContext {
    var submissionInputItems: [SubmissionExtensionItem] { get }
}

@objc
public protocol SubmissionExtensionItem: class {
    var submissionAttachments: [Attachment] { get }
}

extension NSExtensionContext: SubmissionExtensionContext {
    public var submissionInputItems: [SubmissionExtensionItem] {
        return inputItems as? [SubmissionExtensionItem] ?? []
    }
}

extension NSExtensionItem: SubmissionExtensionItem {
    public var submissionAttachments: [Attachment] {
        return attachments as? [Attachment] ?? []
    }
}

// MARK: - Helpers

extension NewUpload {
    var isFileUpload: Bool {
        if case .FileUpload(_) = self { return true }
        return false
    }

    var isNone: Bool {
        if case .None = self { return true }
        return false
    }

    var files: [NewUploadFile] {
        if case .FileUpload(let files) = self {
            return files
        }
        return []
    }

    static func fromUTI(uti: String, withItem item: NSSecureCoding?) -> NewUpload? {
        switch uti {
        case String(kUTTypeText):
            if let text = item as? String {
                return .Text(text)
            }
        case String(kUTTypeFileURL), String(kUTTypeURL):
            if let url = item as? NSURL {
                if url.fileURL {
                    return .FileUpload([.FileURL(url)])
                }
                return .URL(url)
            }
        case String(kUTTypeImage):
            if let image = item as? UIImage {
                return .FileUpload([.Photo(image)])
            }
        case String(kUTTypeMovie), String(kUTTypeAudio):
            if let data = item as? NSData {
                return .FileUpload([.Data(data)])
            }
        case String(kUTTypeItem):
            return fromUTI(String(kUTTypeText), withItem: item) ??
                fromUTI(String(kUTTypeFileURL), withItem: item) ??
                fromUTI(String(kUTTypeURL), withItem: item) ??
                fromUTI(String(kUTTypeImage), withItem: item) ??
                fromUTI(String(kUTTypeMovie), withItem: item) ??
                fromUTI(String(kUTTypeAudio), withItem: item)
        default: break
        }

        return nil
    }
}

extension Attachment {
    func loadItem(uti: String) -> SignalProducer<NewUpload, NSError> {
        return SignalProducer { [weak self] observer, disposable in
            let options = self?.loadItemOptionsForTypeIdentifier(uti)
            self?.loadItemForTypeIdentifier(uti, options: options) { item, error in
                if let item = item {
                    observer.sendNext(NewUpload.fromUTI(uti, withItem: item) ?? .None)
                    observer.sendCompleted()
                } else {
                    observer.sendFailed(error)
                }
            }
        }
    }

    func loadItemOptionsForTypeIdentifier(uti: String) -> [NSObject: AnyObject]? {
        switch uti {
        case String(kUTTypeImage):
            return [NSItemProviderPreferredImageSizeKey: NSValue(CGSize: CGSize(width: 400, height: 400))]
        default: return nil
        }
    }
}
