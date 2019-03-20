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

class DocViewerSession: NSObject, URLSessionTaskDelegate {
    var annotations: [APIDocViewerAnnotation]?
    lazy var api: API = URLSessionAPI(accessToken: nil, baseURL: sessionURL)
    var callback: () -> Void
    var error: Error?
    var localURL: URL?
    var metadata: APIDocViewerMetadata?
    var remoteURL: URL?
    var sessionID: String?
    var sessionURL: URL?
    var task: URLSessionTask?
    lazy var noFollowSession: URLSession? = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)

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

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        completionHandler(nil)
    }

    func load(url: URL, accessToken: String) {
        var request = URLRequest(url: url)
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: HttpHeader.authorization)
        task = noFollowSession?.dataTask(with: request) { [weak self] _, response, error in
            self?.error = error
            if let url = (response as? HTTPURLResponse)?.allHeaderFields["Location"] as? String {
                var components = URLComponents.parse(url)
                components.query = nil
                components.path = components.path.replacingOccurrences(of: "/view", with: "")
                self?.loadMetadata(sessionURL: components.url)
            } else {
                self?.loadMetadata(sessionURL: nil)
            }
            self?.noFollowSession?.invalidateAndCancel()
            self?.noFollowSession = nil
        }
        task?.resume()
    }

    func loadMetadata(sessionURL: URL?) {
        guard error == nil, let sessionURL = sessionURL else { return notify() }
        self.sessionID = sessionURL.lastPathComponent
        self.sessionURL = sessionURL
        task = api.makeRequest(GetDocViewerMetadataRequest(path: sessionURL.absoluteString)) { [weak self] metadata, _, error in
            self?.error = error
            if error == nil, let metadata = metadata, let downloadURL = URL(string: metadata.urls.pdf_download.absoluteString, relativeTo: sessionURL) {
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
            self?.annotations = response?.data ?? []
            if self?.localURL != nil || self?.error != nil { self?.notify() }
        }
    }

    func loadDocument(downloadURL: URL) {
        remoteURL = downloadURL
        task = api.makeDownloadRequest(downloadURL) { [weak self] url, _, error in
            self?.error = error
            if let temp = url, let self = self {
                let fs = FileManager.default
                let perm = fs.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("\(UUID.string).pdf")
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
