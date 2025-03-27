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

import Foundation

public class UploadAvatar {
    var callback: (Result<URL, Error>) -> Void = { _ in }
    let env = AppEnvironment.shared
    var task: APITask?
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func cancel() {
        task?.cancel()
    }

    public func fetch(_ callback: @escaping (Result<URL, Error>) -> Void) {
        self.callback = callback
        getTarget()
    }

    func getTarget() {
        let request = PostFileUploadTargetRequest(context: .myFiles, body: .init(
            name: url.lastPathComponent,
            on_duplicate: .rename,
            parent_folder_path: "profile pictures",
            size: url.lookupFileSize()
        ))
        task = env.api.makeRequest(request) { (data, _, error) in
            guard let target = data, error == nil else {
                return self.callback(.failure(error ?? NSError.internalError()))
            }
            self.upload(target)
        }
    }

    func upload(_ target: FileUploadTarget) {
        task = env.api.makeRequest(
            PostFileUploadRequest(
                fileURL: url,
                target: target,
                isBodyFromURL: false
            )
        ) { data, _, error in
            guard let id = data?.id.value, error == nil else {
                return self.callback(.failure(error ?? NSError.internalError()))
            }
            self.getFile(id: id)
        }
    }

    func getFile(id: String) {
        task = env.api.makeRequest(GetFileRequest(context: .currentUser, fileID: id, include: [ .avatar ])) { data, _, error in
            guard let token = data?.avatar?.token, error == nil else {
                return self.callback(.failure(error ?? NSError.internalError()))
            }
            self.setAvatar(token: token)
        }
    }

    func setAvatar(token: String) {
        task = env.api.makeRequest(PutUserAvatarRequest(token: token)) { data, _, error in
            guard let user = data, let url = user.avatar_url, error == nil else {
                return self.callback(.failure(error ?? NSError.internalError()))
            }
            if let session = self.env.currentSession {
                let updated = LoginSession(
                    accessToken: session.accessToken,
                    baseURL: session.baseURL,
                    expiresAt: session.expiresAt,
                    lastUsedAt: session.lastUsedAt,
                    locale: session.locale,
                    masquerader: session.masquerader,
                    refreshToken: session.refreshToken,
                    userAvatarURL: url.rawValue,
                    userID: session.userID,
                    userName: session.userName,
                    userEmail: session.userEmail,
                    oauthType: session.oauthType
                )
                self.env.currentSession = updated
                if LoginSession.sessions.contains(updated) {
                    LoginSession.add(updated)
                }
            }
            self.callback(.success(url.rawValue))
        }
    }
}
