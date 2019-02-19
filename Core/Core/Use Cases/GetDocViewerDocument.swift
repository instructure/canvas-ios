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

class GetDocViewerDocument: AsyncOperation {
    let api: API
    let downloadURL: URL
    var localURL: URL?
    var task: URLSessionTask?

    init(api: API, downloadURL: URL) {
        self.api = api
        self.downloadURL = downloadURL
    }

    override func execute() {
        guard !isCancelled else { return }

        task = api.makeDownloadRequest(downloadURL) { [weak self] url, _, error in
            self?.addError(error)
            if let temp = url, self != nil {
                let fs = FileManager.default
                let perm = fs.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("\(UUID().uuidString).pdf")
                do {
                    if fs.fileExists(atPath: perm.path) {
                        try fs.removeItem(at: perm)
                    }
                    try fs.copyItem(at: temp, to: perm)
                    self?.localURL = perm
                } catch {
                    self?.addError(error)
                }
            }
            self?.finish()
        }
    }

    override func cancel() {
        super.cancel()
        task?.cancel()
    }
}
