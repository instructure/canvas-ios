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

public class UploadFile: OperationSet {
    let env: AppEnvironment
    let file: URL

    struct UploadParams {
        let target: FileUploadTarget
        let info: FileInfo
    }

    var params: UploadParams?
    var target: PostFileUploadTargetRequest.Response?
    var task: URLSessionTask?

    public init(env: AppEnvironment, file: URL) {
        self.env = env
        self.file = file

        super.init()

        addSequence([
            getUploadParams(),
            getUploadTarget(),
            uploadFile(),
        ])
    }

    override public func cancel() {
        task?.cancel()
        super.cancel()
    }

    private func getUploadParams() -> Operation {
        return DatabaseOperation(database: env.database) { [weak self] client in
            guard let self = self else { return }
            let predicate = NSPredicate(format: "%K == %@", #keyPath(FileUpload.url), self.file as CVarArg)
            if let fileUpload: FileUpload = client.fetch(predicate).first {
                if let target = fileUpload.target {
                    self.env.logger.log("file upload params acquired")
                    self.params = UploadParams(target: target, info: FileInfo(url: fileUpload.url, size: fileUpload.size))
                }
            }
        }
    }

    private func getUploadTarget() -> Operation {
        return AsyncBlockOperation { [weak self] callback in
            guard let params = self?.params, let file = self?.file else {
                return callback(nil)
            }
            let body = PostFileUploadTargetRequest.Body(
                name: file.lastPathComponent,
                on_duplicate: .rename,
                parent_folder_id: nil
            )
            let request = PostFileUploadTargetRequest(
                target: params.target,
                body: body
            )
            self?.task = self?.env.api.makeRequest(request) { response, _, error in
                if let error = error {
                    self?.env.logger.error("failed to get file upload target \(error.localizedDescription)")
                } else {
                    self?.env.logger.log("file upload target acquired")
                }
                self?.target = response
                callback(error)
            }
        }
    }

    private func uploadFile() -> Operation {
        return BlockOperation { [weak self] in
            guard let self = self, let target = self.target else {
                return
            }
            do {
                let request = PostFileUploadRequest(fileURL: self.file, target: target)
                let data = try request.encode(self.file)
                let directory = self.fileUploadDirectory()
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
                let file = directory.appendingPathComponent(self.file.lastPathComponent)
                try data.write(to: file)
                let task = try self.env.backgroundAPI.uploadTask(request, fromFile: file)
                let start = StartFileUpload(backgroundSessionID: self.env.backgroundAPI.identifier!, task: task, database: self.env.database, url: self.file)
                self.addOperation(start)
            } catch {
                let complete = CompleteFileUpload(url: self.file, error: error, database: self.env.database)
                self.addOperation(complete)
                self.env.logger.error(error.localizedDescription)
                self.addError(error)
            }
        }
    }

    private func fileUploadDirectory() -> URL {
        let uuid = UUID().uuidString
        let directory = "file-uploads/\(uuid)"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(directory, isDirectory: true)
        return path
    }
}
