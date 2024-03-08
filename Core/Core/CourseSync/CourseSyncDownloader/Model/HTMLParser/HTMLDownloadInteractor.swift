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

protocol HTMLDownloadInteractor {
    func download(_ url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
    func save(_ result: (data: Data, response: URLResponse)) -> AnyPublisher<URL, Error>
}

class HTMLDownloadInteractorLive: HTMLDownloadInteractor {
    private let loginSession: LoginSession

    init(loginSession: LoginSession) {
        self.loginSession = loginSession
    }

    func download( _ url: URL) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        if url.baseURL == loginSession.baseURL {
            request.setValue("Authentication", forHTTPHeaderField: "Bearer \(loginSession.accessToken ?? "")")
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }

    func save(_ result: (data: Data, response: URLResponse)) -> AnyPublisher<URL, Error> {
        var saveURL = URL.Directories.documents.appendingPathComponent(UUID.string)
        if let url = result.response.url {
            saveURL = URL.Directories.documents.appendingPathComponent("\(UUID.string)\(url.lastPathComponent)")
        }

        do {
            try result.data.write(to: saveURL, options: [.withoutOverwriting])
            return Result.Publisher(saveURL).eraseToAnyPublisher()
        } catch {
            return Result.Publisher(.failure(NSError.instructureError(String(localized: "Failed to save image")))).eraseToAnyPublisher()
        }
    }
}
