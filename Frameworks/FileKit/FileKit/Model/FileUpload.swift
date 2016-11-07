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
import TooLegit
import ReactiveCocoa
import Marshal
import SoLazy

public class FileUpload: Upload {
    @NSManaged public private(set) var data: NSData
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var contentType: String?
    @NSManaged public private(set) var path: String
    @NSManaged public var isInRootFolder: Bool
    @NSManaged public private(set) var parentFolderID: String?
    @NSManaged public var rawContextID: String
    internal (set) public var contextID: ContextID {
        get {
            return ContextID(canvasContext: rawContextID)!
        } set {
            rawContextID = newValue.canvasContextID
        }
    }

    @NSManaged private var targetURL: String?
    @NSManaged private var targetParameters: [String: String]?

    @NSManaged public private(set) var file: File?

    public var disposable = CompositeDisposable()

    public override func cancel() {
        super.cancel()
        disposable.dispose()
    }

    public static func createInContext(context: NSManagedObjectContext) -> FileUpload {
        guard let upload = NSEntityDescription.insertNewObjectForEntityForName(entityName(context), inManagedObjectContext: context) as? FileUpload else {
            ❨╯°□°❩╯⌢"FileUpload not found in data model!"
        }
        return upload
    }
    
    public func prepare(backgroundSessionID: String, path: String, data: NSData, name: String, contentType: String?, parentFolderID: String?, contextID: ContextID) {
        self.backgroundSessionID = backgroundSessionID
        self.path = path
        self.data = data
        self.name = name
        self.contentType = contentType
        self.isInRootFolder = parentFolderID == nil
        self.parentFolderID = parentFolderID
        self.contextID = contextID
    }

    public func begin(inSession session: Session, inContext context: NSManagedObjectContext) {
        disposable += attemptProducer {
            let request = try session.requestPostUploadTarget(path, fileName: name, size: data.length, contentType: contentType, folderPath: nil, overwrite: false)
            let task = session.URLSession.dataTaskWithRequest(request)
            self.startWithTask(task)
            try context.save()
            self.addTaskCompletionHandler(task, inSession: session, inContext: context)
            task.resume()
        }
        .observeOn(ManagedObjectContextScheduler(context: context))
        .flatMapError(saveError(context))
        .start()
    }

    private func saveUploadTargetInContext(context: NSManagedObjectContext) -> (target: UploadTarget) -> SignalProducer<UploadTarget, NSError> {
        return { target in
            return attemptProducer {
                guard let parameters = target.parameters as? [String: String] else {
                    throw NSError(subdomain: "FileKit.FileUpload.UploadTarget", description: "Unexpected target response.")
                }
                self.targetURL = target.url.absoluteString
                self.targetParameters = parameters
                try context.save()
                return target
            }
        }
    }

    private func uploadFile(inSession session: Session, inContext context: NSManagedObjectContext) -> (request: NSMutableURLRequest, fileURL: NSURL) -> SignalProducer<Void, NSError> {
        return { request, fileURL in
            return attemptProducer {
                let task = session.URLSession.uploadTaskWithRequest(request, fromFile: fileURL)
                self.startWithTask(task)
                try context.save()
                self.addTaskCompletionHandler(task, inSession: session, inContext: context)
                session.progressUpdateByTask[task] = { [weak self] bytesSent, totalBytes in
                    context.performBlock({
                        self?.sent = bytesSent
                        self?.total = totalBytes
                    })
                }
                task.resume()
            }
        }
    }

    public func session(session: Session, didFinishTask task: NSURLSessionTask, withResponse json: JSONObject, inContext context: NSManagedObjectContext) {
        guard targetURL != nil && targetParameters != nil else {
            // json should be the upload target
            disposable += UploadTarget.parse(json)
                .flatMap(.Concat, transform: saveUploadTargetInContext(context))
                .flatMap(.Concat, transform: session.requestUploadFile(self.data))
                .flatMap(.Concat, transform: self.uploadFile(inSession: session, inContext: context))
                .observeOn(ManagedObjectContextScheduler(context: context))
                .flatMapError(saveError(context))
                .start()
            return
        }

        // json should be the file
        self.disposable += File.upsert(inContext: context)(jsonArray: [json])
            .flatMap(.Concat) { files in
                SignalProducer(values: files)
                    .flatMap(.Concat) { file in
                        return attemptProducer {
                            self.file = file
                            self.file?.parentFolderID = self.parentFolderID
                            self.file?.isInRootFolder = self.parentFolderID == nil
                            self.file?.contextID = self.contextID
                            self.complete(inSession: session, inContext: context)
                            try context.save()
                        }
                    }
            }
            .observeOn(ManagedObjectContextScheduler(context: context))
            .flatMapError(saveError(context))
            .start()
    }

    public func session(session: Session, didFinishTask task: NSURLSessionTask, withError error: NSError, inContext context: NSManagedObjectContext) {
        context.performChanges {
            self.failWithError(error)
        }
    }

    public func addTaskCompletionHandler(task: NSURLSessionTask, inSession session: Session, inContext context: NSManagedObjectContext) {
        session.completionHandlerByTask[task] = { [weak self] task, error in
            if let data = session.responseDataByTask[task], response = task.response {
                if let result = session.responseJSONSignalProducer(data, response: response).first() {
                    if let json = result.value {
                        self?.session(session, didFinishTask: task, withResponse: json, inContext: context)

                    } else {
                        let error = result.error ?? NSError.invalidResponseError(task.response?.URL)
                        self?.failWithError(error)
                    }
                } else {
                    let error = NSError.invalidResponseError(task.response?.URL)
                    self?.failWithError(error)
                }
            } else {
                let e = error ?? NSError.invalidResponseError(task.response?.URL)
                self?.failWithError(e)
            }
        }
    }

    public func complete(inSession session: Session, inContext context: NSManagedObjectContext) {
        self.complete()
    }

}
