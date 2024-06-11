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

public protocol URLSessionDataTaskPublisherProvider {
    func getPublisher(for: URLRequest) -> AnyPublisher<(tempURL: URL, fileName: String), Error>
}

public class URLSessionDataTaskPublisherProviderLive: URLSessionDataTaskPublisherProvider {

    public init() { }
    public func getPublisher(for request: URLRequest) -> AnyPublisher<(tempURL: URL, fileName: String), Error> {
        return Future { promise in
            Task {
                do {
                    let (url, result) = try await URLSession.shared.download(for: request)
                    promise(.success((tempURL: url, fileName: result.url?.lastPathComponent ?? request.url?.lastPathComponent ?? "")))
                } catch {
                    promise(.failure(NSError.instructureError(error.localizedDescription)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
