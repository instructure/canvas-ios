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
import ReactiveSwift
import SoPersistent
import Marshal

extension Assignment {
    
    fileprivate func apiPathForSubmissionFileUpload(in session: Session) -> SignalProducer<String, NSError> {
        let singleSubmissionPath = SignalProducer<String, NSError>(value: "/api/v1/courses/\(courseID)/assignments/\(id)/submissions/self/files")
        
        if groupSetID != nil {
            let overridesPath = "/api/v1/courses/\(courseID)/assignments/\(id)/overrides"
            let request = try! session.GET(overridesPath)
            
            let firstGroupID: ([JSONObject]) -> String? = { overrides in
                let groupID: (JSONObject) -> String? = {
                    return try? $0.stringID("group_id")
                }
                return overrides
                    .lazy
                    .flatMap(groupID)
                    .first
            }
            
            return session.paginatedJSONSignalProducer(request)
                .map(firstGroupID)
                .skipNil()
                .map { "/api/v1/groups/\($0)/files" }
                .concat(singleSubmissionPath)
                .take(first: 1)
        }

        return singleSubmissionPath
    }

    public func uploadForNewSubmission(_ newSubmission: NewUpload, inSession session: Session, handler: @escaping (SubmissionUpload?)->Void) throws {
        let identifier = submissionUploadIdentifier
        let context = try session.assignmentsManagedObjectContext()
        func convertFile(_ file: NewUploadFile, toUpload fileUploadHandler: @escaping (SubmissionFileUpload?)->Void) {
            
            apiPathForSubmissionFileUpload(in: session)
                .zip(with: file.extractDataProducer)
                .observe(on: ManagedObjectContextScheduler(context: context))
                .startWithResult
            { result in
                guard let (apiPath, optionalData) = result.value, let data = optionalData else {
                    fileUploadHandler(nil)
                    return
                }
                let fileUpload = SubmissionFileUpload(inContext: context)
                fileUpload.prepare(identifier, path: apiPath, data: data, name: file.name, contentType: file.contentType, parentFolderID: nil, contextID: .course(withID: self.courseID))
                fileUploadHandler(fileUpload)
            }
        }

        switch newSubmission {
        case .text(let text):
            let upload = TextSubmissionUpload.create(backgroundSessionID: identifier, assignment: self, text: text, inContext: context)
            handler(upload)
        case .url(let url):
            let upload = URLSubmissionUpload.create(backgroundSessionID: identifier, assignment: self, url: url.absoluteString, inContext: context)
            handler(upload)
        case .mediaComment(let file):
            var fileUploads = [SubmissionFileUpload]()
            convertFile(file) { submissionFileUpload in
                guard let submissionFileUpload = submissionFileUpload else {
                    handler(nil)
                    return
                }
                let upload = FileSubmissionUpload.create(backgroundSessionID: identifier, assignment: self, fileUploads: [submissionFileUpload], inContext: context)
                handler(upload)
            }
        case .fileUpload(let _files):
            func buildFileUpload(_ files: [NewUploadFile], fileUploads: [SubmissionFileUpload]) {
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
        case .none: handler(nil)
        }
    }

    public var submissionUploadIdentifier: String {
        return "assignment-submission-upload-\(id)"
    }

    public func uploadBackgroundSessionExists(_ session: Session) -> Bool {
        do {
            let context = try session.assignmentsManagedObjectContext()
            return try activeBackgroundSessionIDs(context).contains(submissionUploadIdentifier)
        } catch {
            return true // err on the side of caution
        }
    }

    public func uploadSubmission(_ newSubmission: NewUpload, inSession session: Session, uploadHandler: ((SubmissionUpload?)->Void)? = nil) throws {
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

    func activeBackgroundSessionIDs(_ context: NSManagedObjectContext) throws -> [String] {
        let predicate = NSPredicate(format: "%K == %@ && %K != nil && %K == nil", "assignment", self, "startedAt", "terminatedAt")
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.predicate = predicate
        request.entity = NSEntityDescription.entity(forEntityName: SubmissionUpload.entityName(context), in: context)
        request.propertiesToFetch = ["backgroundSessionID"]
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        let results = try context.fetch(request)
        return results.map { ($0 as? [String: String])?["backgroundSessionID"] }.flatMap { $0 }
    }
}
