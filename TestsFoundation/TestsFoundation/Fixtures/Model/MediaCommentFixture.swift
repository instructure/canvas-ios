//
// Copyright (C) 2019-present Instructure, Inc.
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

import Foundation
@testable import Core

extension MediaComment: Fixture {
    public static var template: Template {
        return [
            "contentType": "video/mp4",
            "displayName": "Submission",
            "mediaID": "m-1234567890",
            "mediaType": "video",
            "url": URL(string: "https://google.com")!
        ]
    }
}
