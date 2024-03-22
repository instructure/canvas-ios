//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Combine
import CombineSchedulers

protocol HTMLDownloadInteractor {
    func download(_ url: URL) -> AnyPublisher<(data: Data, response: URLResponse), Error>
    func save(_ result: (data: Data, response: URLResponse), prefix: String) -> AnyPublisher<URL, Error>
}

class HTMLDownloadInteractorLive: HTMLDownloadInteractor {
    private let loginSession: LoginSession
    private let scheduler: AnySchedulerOf<DispatchQueue>

    init(loginSession: LoginSession, scheduler: AnySchedulerOf<DispatchQueue>) {
        self.loginSession = loginSession
        self.scheduler = scheduler
    }

    func download( _ url: URL) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if url.baseURL == loginSession.baseURL {
            request.setValue("Authentication", forHTTPHeaderField: "Bearer \(loginSession.accessToken ?? "")")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { urlError -> Error in
                return urlError
            }
            .receive(on: scheduler)
            .eraseToAnyPublisher()
    }

    func save(_ result: (data: Data, response: URLResponse), prefix: String) -> AnyPublisher<URL, Error> {
        var saveURL = URL.Directories.documents.appendingPathComponent(UUID.string)
        if let url = result.response.url {
            saveURL = URL.Directories.documents.appendingPathComponent("\(prefix)/\(url.lastPathComponent)")
        }

        do {
            let rootURL = URL.Directories.documents.appendingPathComponent("\(prefix)")
            try FileManager.default.createDirectory(atPath: rootURL.path, withIntermediateDirectories: true, attributes: nil)
            FileManager.default.createFile(atPath: saveURL.path, contents: nil)
            try result.data.write(to: saveURL, options: [.atomic, .noFileProtection])
            return Result.Publisher(saveURL).eraseToAnyPublisher()
        } catch {
            print("\(error)")
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save image")))).eraseToAnyPublisher()
        }
    }
}
