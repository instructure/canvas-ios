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


import ReactiveSwift
import Marshal


open class FileUpload: Upload {
    @NSManaged open internal(set) var data: Data
    @NSManaged open internal(set) var name: String
    @NSManaged open internal(set) var contentType: String?
    @NSManaged open internal(set) var path: String
    @NSManaged open var isInRootFolder: Bool
    @NSManaged open fileprivate(set) var parentFolderID: String?

    @NSManaged fileprivate var targetURL: String?
    @NSManaged fileprivate var targetParameters: [String: String]?

    @NSManaged open fileprivate(set) var file: File?
    @NSManaged open fileprivate(set) var batch: FileUploadBatch?

    open var disposable = CompositeDisposable()

    open func abort() {
        cancel()
        disposable.dispose()
    }

    open override func prepareForDeletion() {
        super.prepareForDeletion()

        abort()
    }

    public convenience init(inContext context: NSManagedObjectContext, uploadable: Uploadable, path: String, backgroundSessionID: String = "", parentFolderID: String? = nil, batch: FileUploadBatch? = nil) {
        self.init(
            inContext: context,
            backgroundSessionID: backgroundSessionID,
            path: path,
            data: uploadable.data,
            name: uploadable.name,
            contentType: uploadable.contentType,
            parentFolderID: nil,
            contextID: ContextID(id: "", context: .course),
            batch: batch
        )
    }

    public convenience init(inContext context: NSManagedObjectContext, backgroundSessionID: String, path: String, data: Data, name: String, contentType: String?, parentFolderID: String?, contextID: ContextID, batch: FileUploadBatch? = nil) {
        self.init(inContext: context)
        self.backgroundSessionID = backgroundSessionID
        self.path = path
        self.data = data
        self.name = name
        self.contentType = contentType
        self.isInRootFolder = parentFolderID == nil
        self.parentFolderID = parentFolderID
        self.batch = batch
    }

    open override func reset() {
        super.reset()
        self.targetURL = nil
        self.targetParameters = nil
        self.file = nil
    }

    fileprivate func saveUploadTargetInContext(_ context: NSManagedObjectContext) -> (_ target: UploadTarget) -> SignalProducer<UploadTarget, NSError> {
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

    fileprivate func uploadFile(inSession session: Session, inContext context: NSManagedObjectContext) -> (URLRequest, URL) -> SignalProducer<Void, NSError> {
        return { request, fileURL in
            return attemptProducer {
                let task = session.URLSession.uploadTask(with: request as URLRequest, fromFile: fileURL)
                self.startWithTask(task)
                try context.save()
                self.addTaskCompletionHandler(task, inSession: session, inContext: context)
                session.progressUpdateByTask[task] = { [weak self] bytesSent, totalBytes in
                    context.perform({
                        self?.process(sent: bytesSent, of: totalBytes)
                    })
                }
                self.disposable.add { [weak task] in
                    task?.cancel()
                }
                task.resume()
            }
        }
    }

    open func session(_ session: Session, didFinishTask task: URLSessionTask, withResponse json: JSONObject, inContext context: NSManagedObjectContext) {
        guard targetURL != nil && targetParameters != nil else {
            
            // json should be the upload target
            disposable += UploadTarget.parse(json: json)
                .flatMap(.concat, transform: saveUploadTargetInContext(context))
                .flatMap(.concat, transform: session.requestUploadFile(data: self.data))
                .flatMap(.concat, transform: self.uploadFile(inSession: session, inContext: context))
                .observe(on: ManagedObjectContextScheduler(context: context))
                .flatMapError(saveError(context))
                .start()
            return
        }

        // json should be the file
        self.disposable += File.upsert(inContext: context, jsonArray: [json])
            .flatMap(.concat) { files in
                SignalProducer(files)
                    .flatMap(.concat) { file in
                        return attemptProducer {
                            self.complete(file: file)
                            try context.save()
                        }
                    }
            }
            .flatMapError(saveError(context))
            .start()
    }

    open func addTaskCompletionHandler(_ task: URLSessionTask, inSession session: Session, inContext context: NSManagedObjectContext) {
        session.completionHandlerByTask[task] = { [weak self] task, error in
            if let data = session.responseDataByTask[task], let response = task.response {
                if let result = session.responseJSONSignalProducer(data, response: response).first() {
                    if let json = result.value {
                        self?.session(session, didFinishTask: task, withResponse: json, inContext: context)

                    } else {
                        context.performChanges {
                            let error = result.error ?? NSError.invalidResponseError(task.response?.url)
                            self?.failWithError(error)
                        }
                    }
                } else {
                    context.performChanges {
                        let error = NSError.invalidResponseError(task.response?.url)
                        self?.failWithError(error)
                    }
                }
            } else {
                context.performChanges {
                    let e = error ?? NSError.invalidResponseError(task.response?.url)
                    self?.failWithError(e)
                }
            }
        }
    }
}

extension FileUpload {
    open func begin(inSession session: Session, inContext context: NSManagedObjectContext) {
        disposable = CompositeDisposable()
        disposable += attemptProducer {
            let request = try session.requestPostUploadTarget(path: path, fileName: name, size: data.count, contentType: contentType, folderPath: nil, overwrite: false)
            let task = session.URLSession.dataTask(with: request)
            self.startWithTask(task)
            try context.save()
            self.addTaskCompletionHandler(task, inSession: session, inContext: context)
            self.disposable.add { [weak task] in
                task?.cancel()
            }
            task.resume()
        }
        .observe(on: ManagedObjectContextScheduler(context: context))
        .flatMapError(saveError(context))
        .start()
    }

    internal func complete(file: File) {
        file.parentFolderID = self.parentFolderID
        file.isInRootFolder = self.parentFolderID == nil
        self.file = file
        self.complete()
    }
}
