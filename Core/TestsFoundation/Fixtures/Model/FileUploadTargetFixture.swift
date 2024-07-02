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

extension FileUploadTarget {
    public static func make(
        upload_url: URL = URL(string: "https://canvas.s3.bucket.com/bucket/1")!,
        upload_params: [String: String] = [
            "param1": "foo",
            "param2": "bar"
        ]
    ) -> FileUploadTarget {
        return FileUploadTarget(
            upload_url: upload_url,
            upload_params: upload_params
        )
    }
}
