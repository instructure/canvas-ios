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


import Result

import ReactiveSwift


public final class Uploader {
    public let session: Session
    public let apiPath: String

    public init(session: Session, apiPath: String) {
        self.session = session
        self.apiPath = apiPath
    }

    public func upload(_ uploadable: Uploadable, completed: @escaping (Result<File, NSError>) -> ()) throws {
        let context = try self.session.filesManagedObjectContext()
        let fileUpload = FileUpload(inContext: context, uploadable: uploadable, path: self.apiPath)

        let token = Lifetime.Token()
        let predicate = NSPredicate(format: "self == %@", fileUpload)
        let observer = try FileUpload.observer(session: self.session, predicate: predicate)
            .take(during: Lifetime(token))

        self.disposable?.dispose()
        let disposable = CompositeDisposable()

        disposable += observer
            .filter { $0.hasCompleted }
            .map { $0.file! }
            .take(first: 1)
            .observeValues { file in
                completed(Result(value: file))
            }

        observer
            .map { $0.errorMessage }
            .skipNil()
            .take(first: 1)
            .observeValues { errorMessage in
                let error = NSError(subdomain: "FileKit", description: errorMessage)
                completed(Result(error: error))
            }

        disposable.add { [weak self] in
            self?.notificationCenterToken = nil
        }

        self.notificationCenterToken = token
        self.fileUpload = fileUpload
        self.disposable = disposable

        fileUpload.begin(inSession: self.session, inContext: context)
    }

    public func cancel() {
        fileUpload?.abort()
        disposable?.dispose()
    }

    private var notificationCenterToken: Lifetime.Token?
    private var fileUpload: FileUpload?
    private var disposable: CompositeDisposable?
}
