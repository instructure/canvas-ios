//
// Copyright (C) 2017-present Instructure, Inc.
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
