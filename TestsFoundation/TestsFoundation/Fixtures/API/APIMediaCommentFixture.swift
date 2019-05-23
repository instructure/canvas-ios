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

extension APIMediaComment {
    public static func make(
        content_type: String = "video/mp4",
        display_name: String? = "Submission",
        media_id: String = "m-1234567890",
        media_type: MediaCommentType = .video,
        url: URL = URL(string: "https://google.com")!
    ) -> APIMediaComment {
        return APIMediaComment(
            content_type: content_type,
            display_name: display_name,
            media_id: media_id,
            media_type: media_type,
            url: url
        )
    }
}
