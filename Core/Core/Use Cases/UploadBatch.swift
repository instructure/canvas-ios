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
    public class Token: NSObject {}
    public typealias Callback = (State?) -> Void

    public enum State: Equatable {
        case staged
        case uploading
        case failed(Error)
        case completed(fileIDs: Set<String>)

        public static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.staged, .staged): return true
            case (.uploading, .uploading): return true
            case (.failed, .failed): return true
            case let (.completed(fileIDs: lhs), .completed(fileIDs: rhs)): return lhs == rhs
            default: return false
            }
        }
    }

    let env: AppEnvironment
    public let batchID: String
    public lazy var files: Store<LocalUseCase<File>> = env.subscribe(scope: .where(#keyPath(File.batchID), equals: batchID)) { [weak self] in
        self?.update()
    }
    private var subscribers: [Token: Callback] = [:]
    public var state: State?
    public var uploader: FileUploader = UploadFile.shared
    var token: Token?

    public init(environment: AppEnvironment = .shared, batchID: String = UUID.string, callback: Callback?) {
        self.env = environment
        self.batchID = batchID

        if let callback = callback {
            token = subscribe(callback)
        }

        files.refresh()
    }

    deinit {
        if let token = token {
            unsubscribe(token)
        }
    }

    @discardableResult
    public func subscribe(_ callback: @escaping Callback) -> Token {
        let token = Token()
        subscribers[token] = callback
        callback(state)
        return token
    }

    public func unsubscribe(_ token: Token) {
        subscribers.removeValue(forKey: token)
    }

    private func notify() {
        for (_, callback) in subscribers {
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

    @discardableResult
    public func upload(to context: FileUploadContext, callback: Callback? = nil) -> Token? {
        var token: Token?
        if let callback = callback {
            token = subscribe(callback)
        }
        self.state = nil
        for file in files {
            uploader.upload(file, context: context) { error in
                if let error = error {
                    callback?(.failed(error))
                }
            }
        }
        return token
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
            let fileIDs = Set(files.compactMap { $0.id })
            if state == .completed(fileIDs: fileIDs) { return }
            state = .completed(fileIDs: fileIDs)
        } else if let error = files.compactMap({ $0.uploadError }).first {
            let error = NSError.instructureError(error)
            if state == .failed(error) { return }
            state = State.failed(error)
        } else if files.first(where: { $0.isUploading }) != nil {
            state = .uploading
        } else {
            state = .staged
        }
        notify()
    }
}
