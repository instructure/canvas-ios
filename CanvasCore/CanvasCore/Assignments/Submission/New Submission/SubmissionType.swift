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

public enum SubmissionType {
    case text
    case url
    case fileUpload

    var title: String {
        switch self {
        case .text:
            return NSLocalizedString("Enter Text",
                                     tableName: "Localizable",
                                     bundle: .core,
                                     value: "",
                                     comment: "Text submission option")
        case .url:
            return NSLocalizedString("Add Website Address",
                                     tableName: "Localizable",
                                     bundle: .core,
                                     value: "",
                                     comment: "URL submission option")
        case .fileUpload:
            return NSLocalizedString("Upload File",
                                     tableName: "Localizable",
                                     bundle: .core,
                                     value: "",
                                     comment: "File upload submission option")
        }
    }
}
