//
// Copyright (C) 2017-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
