//
// Copyright (C) 2018-present Instructure, Inc.
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

public class DownloadFile: OperationSet {
    let fileID: String
    let userID: String
    let database: Persistence
    let api: API

    private var downloadTask: URLSessionTask?
    private var serverFileURL: URL?
    private var localFileURL: URL?
    private var fileName: String?
    private var file: File?

    public init (fileID: String, userID: String, env: AppEnvironment = .shared) {
        self.fileID = fileID
        self.userID = userID
        self.api = env.api
        self.database = env.database
        super.init()

        addSequence([
            fileFromPersistence(),
            downloadFile(),
            persistFileURL(),
        ])
    }

    override public func cancel() {
        downloadTask?.cancel()
        super.cancel()
    }

    func fileFromPersistence() -> Operation {
        return DatabaseOperation(database: database) { [weak self] client in
            guard let fileID = self?.fileID else {
                return
            }
            let scope = File.scope(forName: .details(fileID))
            guard let file: File = client.fetch(predicate: scope.predicate, sortDescriptors: nil).first else {
                return
            }
            self?.serverFileURL = file.url
            self?.fileName = file.filename
        }
    }

    func downloadFile() -> Operation {
        return AsyncBlockOperation(block: { [weak self] (completionBlock: @escaping (Error?) -> Void) in
            guard let fileID = self?.fileID, let userID = self?.userID, let fileName = self?.fileName, let serverFileURL = self?.serverFileURL else {
                completionBlock(nil)
                return
            }

            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let host = self?.api.baseURL.host else {
                completionBlock(nil)
                return
            }

            self?.downloadTask = self?.api.makeDownloadRequest(serverFileURL) { (tempLocalURL, _, error) in
                if error != nil {
                    completionBlock(error)
                    return
                }

                guard let tempLocalURL = tempLocalURL else {
                    completionBlock(nil)
                    return
                }

                do {
                    let directory = documentsURL.appendingPathComponent(host).appendingPathComponent(userID).appendingPathComponent("files").appendingPathComponent(fileID)
                    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                    let localFileURL = directory.appendingPathComponent(fileName)
                    if FileManager.default.fileExists(atPath: localFileURL.path) {
                        try FileManager.default.removeItem(at: localFileURL)
                    }
                    try FileManager.default.copyItem(at: tempLocalURL, to: localFileURL)
                    self?.localFileURL = localFileURL
                    completionBlock(nil)
                } catch {
                    completionBlock(error)
                }
            }
        })
    }

    func persistFileURL() -> Operation {
        return DatabaseOperation(database: database, block: { [weak self] client in
            guard let fileID = self?.fileID, let localFileURL = self?.localFileURL else {
                return
            }
            let scope = File.scope(forName: .details(fileID))
            guard let file: File = client.fetch(predicate: scope.predicate, sortDescriptors: nil).first else {
                return
            }
            file.localFileURL = localFileURL
        })
    }
}
