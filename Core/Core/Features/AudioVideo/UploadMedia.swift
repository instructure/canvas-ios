//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import Foundation

public class UploadMedia: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    let env = AppEnvironment.shared
    let database = UploadManager.shared.database
    var mediaAPI: API?
    var task: APITask?
    var callback: (String?, Error?) -> Void = { _, _ in }
    let file: File?
    let url: URL
    let type: MediaCommentType
    var isUploading = false
    let context: Context?

    public init(type: MediaCommentType, url: URL, file: File? = nil, context: Context? = nil) {
        self.file = file
        self.type = type
        self.url = url
        self.context = context
    }

    public func cancel() {
        task?.cancel()
        if let file = file {
            UploadManager.shared.cancel(file: file)
        }
    }

    public func fetch(_ callback: @escaping (String?, Error?) -> Void) {
        self.callback = callback
        upload()
    }

    func upload() {
        task = env.api.makeRequest(GetMediaServiceRequest()) { (data, _, error) in
            var url: URL?
            if let domain = data?.domain,
                domain.starts(with: "http://localhost:") {
                url = URL(string: domain)
            } else if let domain = data?.domain.replacingOccurrences(of: "https://", with: "") {
                url = URL(string: "https://\(domain)")
            }
            guard let baseUrl = url, error == nil else {
                return self.callback(nil, error)
            }
            self.mediaAPI = API(baseURL: baseUrl, urlSession: URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil))
            self.getSession()
        }
    }

    func getSession() {
        task = env.api.makeRequest(PostMediaSessionRequest()) { (data, _, error) in
            guard error == nil, let ks = data?.ks else {
                return self.callback(nil, error)
            }
            self.getUploadToken(ks: ks)
        }
    }

    func getUploadToken(ks: String) {
        task = mediaAPI?.makeRequest(PostMediaUploadTokenRequest(body: .init(ks: ks))) { (data, _, error) in
            guard error == nil, let token = data?.id, !token.isEmpty else {
                return self.callback(nil, error)
            }
            self.postUpload(ks: ks, token: token)
        }
    }

    func postUpload(ks: String, token: String) {
        isUploading = true
        task = mediaAPI?.makeRequest(PostMediaUploadRequest(fileURL: url, type: type, ks: ks, token: token)) { (_, _, error) in
            self.isUploading = false
            guard error == nil else {
                return self.callback(nil, error)
            }
            self.getMediaID(ks: ks, token: token)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard isUploading, let id = file?.objectID else { return }
        database.performBackgroundTask { (context: NSManagedObjectContext) in
            guard let file = try? context.existingObject(with: id) as? File else { return }
            file.bytesSent = Int(totalBytesSent)
            file.size = Int(totalBytesExpectedToSend)
            do {
                try context.save()
            } catch {
                Logger.shared.error(error)
            }
        }
    }

    func getMediaID(ks: String, token: String) {
        task = mediaAPI?.makeRequest(PostMediaIDRequest(ks: ks, token: token, type: type)) { (data, _, error) in
            guard error == nil, let mediaID = data?.id, !mediaID.isEmpty else {
                return self.callback(nil, error)
            }
            self.completeUpload(mediaID: mediaID)
        }
    }

    func completeUpload(mediaID: String) {
        guard let context = context else {
            return self.callback(mediaID, nil)
        }
        let request = PostCompleteMediaUploadRequest(mediaID: mediaID, context: context, type: type)
        task = env.api.makeRequest(request) { response, _, error in
            self.callback(response?.media_object.media_id, error)
        }
    }
}
