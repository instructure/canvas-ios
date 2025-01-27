//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
import CombineExt

/**
 This class returns the base url for a given context. To achieve this it requests the HEAD of the given context
 from the API and extracts the base url from the http header fields.
 */
public class ContextBaseURLInteractor {
    private let api: API

    public init(api: API) {
        self.api = api
    }

    public func getBaseURL(context: Context) -> AnyPublisher<URL, Error> {
        api
            .makeRequest(GetContextHead(context: context))
            .tryMap {
                guard let securityHeader = $0.urlResponse?.allHeaderFields["content-security-policy"] as? String else {
                    throw NSError.instructureError("Missing content-security-policy header.")
                }
                return securityHeader
            }
            .tryMap {
                guard let url = $0.extractFirstURL() else {
                    throw NSError.instructureError("Failed to extract base url from http header fields.")
                }
                return url
            }
            .eraseToAnyPublisher()
    }
}

private extension String {

    /**
     Extracts the first url from the frame-ancestors directive within the content-security-policy http header.
     Example format of such a header:
     frame-ancestors \'self\' test.instructure.com test.staging.instructure.com test.beta.instructure.com;
     */
    func extractFirstURL() -> URL? {
        var frameAncestorComponents = self
            .split(separator: ";")
            .first { $0.trimmingCharacters(in: .whitespaces).hasPrefix("frame-ancestors") }?
            .split(separator: " ")
        frameAncestorComponents?.removeAll {
            $0 == "frame-ancestors" || $0 == "'self'"
        }

        for urlEntry in frameAncestorComponents ?? [] {
            if let url = URL(string: "https://\(urlEntry)") {
                return url
            }
        }

        return nil
    }
}
