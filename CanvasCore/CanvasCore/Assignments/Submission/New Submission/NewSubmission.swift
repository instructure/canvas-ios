//
// Copyright (C) 2016-present Instructure, Inc.
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



public enum NewSubmission {
    case fileUpload([File])
    case text(String)
    case url(URL)
    case arc(URL)

    var parameters: [String: Any] {
        switch self {
        case .fileUpload(let files):
            return [
                "submission_type": "online_upload",
                "file_ids": files.map { $0.id }
            ]
        case .text(let text):
            return [
                "submission_type": "online_text_entry",
                "body": text
            ]
        case .url(let url):
            return [
                "submission_type": "online_url",
                "url": url.absoluteString
            ]
        case .arc(let url):
            return [
                "submission_type": "basic_lti_launch",
                "url": url.absoluteString
            ]
        }
    }
}
