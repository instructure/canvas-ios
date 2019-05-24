//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
