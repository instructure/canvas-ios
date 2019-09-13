//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import CoreData
import ReactiveSwift
import Marshal
import Core

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

    @objc open func abort() {
        cancel()
        disposable.dispose()
    }

    open override func prepareForDeletion() {
        super.prepareForDeletion()

        abort()
    }

    @objc public convenience init(inContext context: NSManagedObjectContext, uploadable: Uploadable, path: String, backgroundSessionID: String = "", parentFolderID: String? = nil, batch: FileUploadBatch? = nil) {
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
                let task = session.URLSession.uploadTask(with: request as URLRequest, fromFile: fileURL) { [weak self] data, urlResponse, error in
                    self?.taskCompletionHandler(session: session, context: context, data: data, response: urlResponse, error: error)
                }
                self.startWithTask(task)
                try context.save()
                self.disposable.add { [weak task] in
                    task?.cancel()
                }
                task.resume()
            }
        }
    }

    @objc open func session(_ session: Session, withResponse json: JSONObject, inContext context: NSManagedObjectContext) {
        guard targetURL != nil && targetParameters != nil else {
            
            // json should be the upload target
            disposable += UploadTarget.parse(json: json)
                .flatMap(.concat, saveUploadTargetInContext(context))
                .flatMap(.concat, session.requestUploadFile(data: self.data))
                .flatMap(.concat, self.uploadFile(inSession: session, inContext: context))
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

    @objc open func taskCompletionHandler(session: Session, context: NSManagedObjectContext, data: Data?, response: URLResponse?, error: Error?) {
        if let data = data, let response = response {
            if let result = session.responseJSONSignalProducer(data, response: response).first() {
                if let json = result.value {
                    self.session(session, withResponse: json, inContext: context)
                } else {
                    context.performChanges {
                        let error = result.error ?? NSError.invalidResponseError(response.url)
                        self.failWithError(error)
                    }
                }
            } else {
                context.performChanges {
                    let error = NSError.invalidResponseError(response.url)
                    self.failWithError(error)
                }
            }
        } else {
            context.performChanges {
                let e = error ?? NSError.invalidResponseError(response?.url)
                self.failWithError(e as NSError)
            }
        }
    }
}

extension FileUpload {
    @objc open func begin(inSession session: Session, inContext context: NSManagedObjectContext) {
        disposable = CompositeDisposable()
        disposable += attemptProducer {
            let request = try session.requestPostUploadTarget(path: path, fileName: name, size: data.count, contentType: contentType, folderPath: nil, overwrite: false)
            let task = session.api.makeRequest(request) { [weak self] data, response, error in
                self?.taskCompletionHandler(session: session, context: context, data: data, response: response, error: error)
            }
            if let t = task {
                self.startWithTask(t)
            }
            try context.save()
            self.disposable.add { [weak task] in
                task?.cancel()
            }
        }
        .observe(on: ManagedObjectContextScheduler(context: context))
        .flatMapError(saveError(context))
        .start()
    }

    @objc internal func complete(file: File) {
        file.parentFolderID = self.parentFolderID
        file.isInRootFolder = self.parentFolderID == nil
        self.file = file
        self.complete()
    }
}
