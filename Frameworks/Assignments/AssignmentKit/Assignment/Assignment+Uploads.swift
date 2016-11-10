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
    
    

import TooLegit
import CoreData
import SoLazy
import FileKit
import ReactiveCocoa
import SoPersistent
import Marshal

extension Assignment {
    
    private func apiPathForSubmissionFileUpload(in session: Session) -> SignalProducer<String, NSError> {
        let singleSubmissionPath = SignalProducer<String, NSError>(value: "/api/v1/courses/\(courseID)/assignments/\(id)/submissions/self/files")
        
        if groupSetID != nil {
            let overridesPath = "/api/v1/courses/\(courseID)/assignments/\(id)/overrides"
            let request = try! session.GET(overridesPath)
            return session.paginatedJSONSignalProducer(request)
                .flatMap(.Merge, transform: { (overrides) -> SignalProducer<String, NSError> in
                    for overrideJSON in overrides {
                        if let groupID: String = try? overrideJSON.stringID("group_id") {
                            return SignalProducer<String, NSError>(value: groupID)
                        }
                    }
                    return .empty
                })
                .map { "/api/v1/groups/\($0)/files" }
                .concat(singleSubmissionPath)
                .take(1)
        }

        return singleSubmissionPath
    }

    public func uploadForNewSubmission(newSubmission: NewUpload, inSession session: Session, handler: SubmissionUpload?->Void) throws {
        let identifier = submissionUploadIdentifier
        let context = try session.assignmentsManagedObjectContext()
        func convertFile(file: NewUploadFile, toUpload fileUploadHandler: SubmissionFileUpload?->Void) {
            
            apiPathForSubmissionFileUpload(in: session)
                .zipWith(file.extractDataProducer)
                .observeOn(ManagedObjectContextScheduler(context: context))
                .startWithResult
            { result in
                guard let (apiPath, optionalData) = result.value, data = optionalData else {
                    fileUploadHandler(nil)
                    return
                }
                let fileUpload = SubmissionFileUpload(inContext: context)
                fileUpload.prepare(identifier, path: apiPath, data: data, name: file.name, contentType: file.contentType, parentFolderID: nil, contextID: ContextID(id: self.id, context: .Course))
                fileUploadHandler(fileUpload)
            }
        }

        switch newSubmission {
        case .Text(let text):
            let upload = TextSubmissionUpload.create(backgroundSessionID: identifier, assignment: self, text: text, inContext: context)
            handler(upload)
        case .URL(let url):
            let upload = URLSubmissionUpload.create(backgroundSessionID: identifier, assignment: self, url: url.absoluteString!, inContext: context)
            handler(upload)
        case .MediaComment(let file):
            var fileUploads = [SubmissionFileUpload]()
            convertFile(file) { submissionFileUpload in
                guard let submissionFileUpload = submissionFileUpload else {
                    handler(nil)
                    return
                }
                let upload = FileSubmissionUpload.create(backgroundSessionID: identifier, assignment: self, fileUploads: [submissionFileUpload], inContext: context)
                handler(upload)
            }
        case .FileUpload(let _files):
            func buildFileUpload(files: [NewUploadFile], fileUploads: [SubmissionFileUpload]) {
                if files.isEmpty {
                    // make sure all the files were converted
                    if fileUploads.count != _files.count {
                        handler(nil)
                        return
                    }

                    let upload = FileSubmissionUpload.create(backgroundSessionID: identifier, assignment: self, fileUploads: fileUploads, inContext: context)
                    handler(upload)
                    return
                }

                var mutableFiles = files
                guard let file = mutableFiles.popLast() else {
                    // something weird happened
                    handler(nil)
                    return
                }

                convertFile(file) { submissionFileUpload in
                    if let submissionFileUpload = submissionFileUpload {
                        buildFileUpload(mutableFiles, fileUploads: fileUploads + [submissionFileUpload])
                    } else {
                        handler(nil)
                    }
                }
            }

            buildFileUpload(_files, fileUploads: [])
        case .None: handler(nil)
        }
    }

    public var submissionUploadIdentifier: String {
        return "assignment-submission-upload-\(id)"
    }

    public func uploadBackgroundSessionExists(session: Session) -> Bool {
        do {
            let context = try session.assignmentsManagedObjectContext()
            return try activeBackgroundSessionIDs(context).contains(submissionUploadIdentifier)
        } catch {
            return true // err on the side of caution
        }
    }

    public func uploadSubmission(newSubmission: NewUpload, inSession session: Session, uploadHandler: (SubmissionUpload?->Void)? = nil) throws {
        let context = try session.assignmentsManagedObjectContext()
        try uploadForNewSubmission(newSubmission, inSession: session) { upload in
            guard let upload = upload else {
                uploadHandler?(nil)
                return
            }

            upload.begin(inSession: session, inContext: context)
            uploadHandler?(upload)
        }
    }

    func activeBackgroundSessionIDs(context: NSManagedObjectContext) throws -> [String] {
        let predicate = NSPredicate(format: "%K == %@ && %K != nil && %K == nil", "assignment", self, "startedAt", "terminatedAt")
        let request = SubmissionUpload.fetch(predicate, sortDescriptors: nil, inContext: context)
        request.entity = NSEntityDescription.entityForName(SubmissionUpload.entityName(context), inManagedObjectContext: context)
        request.propertiesToFetch = ["backgroundSessionID"]
        request.resultType = .DictionaryResultType
        request.returnsDistinctResults = true
        let results = try context.executeFetchRequest(request)
        return results.map { ($0 as? [String: String])?["backgroundSessionID"] }.flatMap { $0 }
    }
}
