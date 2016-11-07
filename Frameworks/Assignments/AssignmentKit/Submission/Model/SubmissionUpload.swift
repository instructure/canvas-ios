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
    
    

import CoreData
import SoPersistent
import SoLazy
import TooLegit
import ReactiveCocoa
import Result
import Marshal
import FileKit

public class SubmissionUpload: Upload {
    @NSManaged private(set) var comment: String?
    @NSManaged private(set) var assignment: Assignment
    @NSManaged private(set) var submission: Submission?

    var parameters: [String: AnyObject] {
        return [:]
    }

    var submissionsPath: String {
        return "/api/v1/courses/\(assignment.courseID)/assignments/\(assignment.id)/submissions"
    }

    var disposable = CompositeDisposable()

    public override func cancel() {
        super.cancel()
        disposable.dispose()
    }

    public func begin(inSession session: Session, inContext context: NSManagedObjectContext) {
        var parameters: [String: AnyObject] = ["submission": self.parameters]
        if let comment = comment {
            parameters["comment"] = comment
        }

        disposable += (attemptProducer {
            let request = try session.POST(submissionsPath, parameters: parameters)
            let task = session.URLSession.dataTaskWithRequest(request)
            self.startWithTask(task)
            try context.save()
            return task
        } as SignalProducer<NSURLSessionTask, NSError>)
        .flatMap(.Concat, transform: session.JSONSignalProducer)
            .map { [$0] }
            .flatMap(.Concat, transform: Submission.upsert(inContext: context))
            .flatMap(.Concat) { SignalProducer<Submission, NSError>(values: $0) }
            .flatMap(.Concat) { submission in
                return attemptProducer {
                    self.submission = submission
                    self.complete()
                    try context.save()
                }
            }
            .flatMapError(saveError(context))
            .observeOn(ManagedObjectContextScheduler(context: context))
            .start()
    }
}

public final class TextSubmissionUpload: SubmissionUpload {
    @NSManaged private(set) var text: String

    override var parameters: [String : AnyObject] {
        return [
            "submission_type": "online_text_entry",
            "body": text
        ]
    }

    static func create(backgroundSessionID backgroundSessionID: String, assignment: Assignment, text: String, comment: String? = nil, inContext context: NSManagedObjectContext) -> TextSubmissionUpload {
        let upload = TextSubmissionUpload(inContext: context)
        upload.backgroundSessionID = backgroundSessionID
        upload.assignment = assignment
        upload.text = text
        upload.comment = comment
        return upload
    }
}

public final class URLSubmissionUpload: SubmissionUpload {
    @NSManaged private(set) var url: String

    override var parameters: [String : AnyObject] {
        return [
            "submission_type": "online_url",
            "url": url
        ]
    }

    static func create(backgroundSessionID backgroundSessionID: String, assignment: Assignment, url: String, comment: String? = nil, inContext context: NSManagedObjectContext) -> URLSubmissionUpload {
        let upload = URLSubmissionUpload(inContext: context)
        upload.backgroundSessionID = backgroundSessionID
        upload.assignment = assignment
        upload.url = url
        upload.comment = comment
        return upload
    }
}

public final class FileSubmissionUpload: SubmissionUpload {
    @NSManaged private(set) var fileUploads: Set<SubmissionFileUpload>

    override var parameters: [String : AnyObject] {
        return [
            "submission_type": "online_upload",
            "file_ids": fileUploads.map { $0.file?.id }.flatMap { $0 }
        ]
    }

    static func create(backgroundSessionID backgroundSessionID: String, assignment: Assignment, fileUploads: [SubmissionFileUpload], comment: String? = nil, inContext context: NSManagedObjectContext) -> FileSubmissionUpload {
        let upload: FileSubmissionUpload = create(inContext: context)
        upload.backgroundSessionID = backgroundSessionID
        upload.assignment = assignment
        upload.comment = comment
        upload.fileUploads = Set(fileUploads)
        return upload
    }

    var allFileUploadsCompleted: Bool {
        return fileUploads.reduce(true) { $0 && $1.hasCompleted }
    }

    public override func begin(inSession session: Session, inContext context: NSManagedObjectContext) {
        fileUploads.forEach { $0.begin(inSession: session, inContext: context) }
    }

    func submissionFileUpload(submissionFileUpload: SubmissionFileUpload, finishedInSession session: Session, inContext context: NSManagedObjectContext) {
        if allFileUploadsCompleted {
            super.begin(inSession: session, inContext: context)
        }
    }

    func submissionFileUpload(submissionFileUpload: SubmissionFileUpload, failedWithError error: NSError) {
        fileUploads.filter { $0.isInProgress }.forEach { $0.cancel() }
        failWithError(error)
    }
}

public final class SubmissionFileUpload: FileUpload {
    @NSManaged private(set) var fileSubmissionUpload: FileSubmissionUpload
    
    public override func complete(inSession session: Session, inContext context: NSManagedObjectContext) {
        super.complete()
        fileSubmissionUpload.submissionFileUpload(self, finishedInSession: session, inContext: context)
    }

    public override func failWithError(error: NSError) {
        super.failWithError(error)
        fileSubmissionUpload.submissionFileUpload(self, failedWithError: error)
    }

    public func addCompletionHandler(inSession session: Session) throws {
        let context = try session.assignmentsManagedObjectContext()
        session.addFileUploadCompletionHandler(self, inContext: context)
    }
}
