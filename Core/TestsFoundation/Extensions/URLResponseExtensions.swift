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
@testable import Core

extension URLResponse {
    public static var httpSuccess: URLResponse {
        return HTTPURLResponse(url: .stub, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: [
            HttpHeader.contentType: "application/json"
        ])!
    }
}

extension HTTPURLResponse {
    public convenience init(next: String) {
        let headers = [
            "Link": "<\(next)>; rel=\"next\"; count=1"
        ]
        self.init(url: .stub, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
    }
}
