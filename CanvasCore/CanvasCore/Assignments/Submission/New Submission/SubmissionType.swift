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
