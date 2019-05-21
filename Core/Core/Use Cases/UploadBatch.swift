//
// Copyright (C) 2019-present Instructure, Inc.
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

import Foundation

public class UploadBatch {
    public typealias Callback = (State?) -> Void

    public enum State: Equatable {
        case staged
        case uploading
        case failed(Error)
        case completed(fileIDs: [String])

        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.staged, .staged): return true
            case (.uploading, .uploading): return true
            case (.failed, .failed): return true
            case (.completed, .completed): return true
            default: return false
            }
        }

        public var completed: Bool {
            switch self {
            case .completed: return true
            default: return false
            }
        }

        public var failed: Bool {
            switch self {
            case .failed: return true
            default: return false
            }
        }
    }

    let env: AppEnvironment
    public let batchID: String
    public lazy var files: Store<LocalUseCase<File>> = env.subscribe(scope: .where(#keyPath(File.batchID), equals: batchID)) { [weak self] in
        self?.update()
    }
    private var subscribers: [Callback] = []
    public var state: State?
    public var uploader: FileUploader = UploadFile.shared

    public init(environment: AppEnvironment = .shared, batchID: String = UUID.string, callback: Callback?) {
        self.env = environment
        self.batchID = batchID

        if let callback = callback {
            subscribe(callback)
        }

        files.refresh()
    }

    public func subscribe(_ callback: @escaping Callback) {
        subscribers.append(callback)
        callback(state)
    }

    private func notify() {
        for callback in subscribers {
            callback(state)
        }
    }

    public func addFile(_ url: URL) throws {
        let context = env.database.viewContext
        var error: Error?
        context.performAndWait {
            do {
                let file: File = context.insert()
                file.batchID = self.batchID
                file.localFileURL = url
                file.size = url.lookupFileSize()
                try context.save()
            } catch let e {
                error = e
            }
        }
        if let e = error {
            throw e
        }
    }

    public func upload(to context: FileUploadContext, callback: Callback? = nil) {
        if let callback = callback { subscribe(callback) }
        self.state = nil
        for file in files {
            uploader.upload(file, context: context) { error in
                if let error = error {
                    callback?(.failed(error))
                }
            }
        }
    }

    public func cancel() {
        let context = env.database.viewContext
        context.performAndWait {
            for file in self.files {
                self.uploader.cancel(file)
                context.delete(file)
                try? context.save()
            }
        }
    }

    func update() {
        if files.isEmpty {
            state = nil
        } else if files.allSatisfy({ $0.isUploaded }) {
            guard state?.completed != true else { return }
            state = .completed(fileIDs: files.compactMap { $0.id })
        } else if let error = files.compactMap({ $0.uploadError }).first {
            guard state?.failed != true else { return }
            state = State.failed(NSError.instructureError(error))
        } else if files.first(where: { $0.isUploading }) != nil {
            state = .uploading
        } else {
            state = .staged
        }
        notify()
    }
}
