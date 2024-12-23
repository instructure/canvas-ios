//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation

public class DocViewerSession: NSObject, URLSessionTaskDelegate {
    var annotations: [APIDocViewerAnnotation]?
    lazy var api: API = API(baseURL: sessionURL)
    var callback: () -> Void
    var error: Error?
    var localURL: URL?
    var metadata: APIDocViewerMetadata?
    var remoteURL: URL?
    var sessionID: String?
    var sessionURL: URL?
    var task: APITask?

    init(callback: @escaping () -> Void) {
        self.callback = callback
        super.init()
    }

    func notify() {
        callback()
    }

    func cancel() {
        task?.cancel()
    }

    func load(url: URL, session: LoginSession) {
        task?.cancel()
        task = API(session, urlSession: .noFollowRedirect).makeRequest(url) { [weak self] _, response, error in
            self?.error = error
            if let url = (response as? HTTPURLResponse)?.allHeaderFields["Location"] as? String {
                var components = URLComponents.parse(url)
                components.query = nil
                components.path = components.path.replacingOccurrences(of: "/view", with: "")
                self?.loadMetadata(sessionURL: components.url)
            } else {
                self?.loadMetadata(sessionURL: nil)
            }
        }
    }

    func loadMetadata(sessionURL: URL?) {
        guard error == nil, let sessionURL = sessionURL else { return notify() }
        self.sessionID = sessionURL.lastPathComponent
        self.sessionURL = sessionURL
        task = api.makeRequest(GetDocViewerMetadataRequest(path: sessionURL.absoluteString)) { [weak self] metadata, response, error in
            if (response as? HTTPURLResponse)?.statusCode == 202 {
                DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
                    self?.loadMetadata(sessionURL: sessionURL)
                }
                return
            }
            self?.error = error
            if error == nil, let metadata = metadata, let downloadURL = URL(string: metadata.urls.pdf_download.relativeString, relativeTo: sessionURL) {
                self?.metadata = metadata
                self?.loadAnnotations()
                self?.loadDocument(downloadURL: downloadURL)
            } else {
                self?.notify()
            }
        }
    }

    func loadAnnotations() {
        guard metadata?.annotations?.enabled == true else {
            annotations = []
            return
        }
        _ = api.makeRequest(GetDocViewerAnnotationsRequest(sessionID: sessionID ?? "")) { [weak self] response, _, _ in
            self?.annotations = response?.data.sorted() ?? []
            if self?.localURL != nil || self?.error != nil { self?.notify() }
        }
    }

    func loadDocument(downloadURL: URL) {
        remoteURL = downloadURL
        task = api.makeDownloadRequest(downloadURL) { [weak self] url, _, error in
            self?.error = error
            if let temp = url, let self = self {
                let fs = FileManager.default
                let perm = URL.Directories.temporary.appendingPathComponent("\(UUID.string).pdf")
                do {
                    if fs.fileExists(atPath: perm.path) {
                        try fs.removeItem(at: perm)
                    }
                    try fs.copyItem(at: temp, to: perm)
                    self.localURL = perm
                } catch {
                    self.error = error
                }
            }
            if self?.annotations != nil { self?.notify() }
        }
    }
}
