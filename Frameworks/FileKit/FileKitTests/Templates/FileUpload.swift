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

import TooLegit
@testable import FileKit
import SoPersistent

extension FileUpload {
    static func template(session: Session) -> FileUpload {
        return FileUpload(
            inContext: try! session.filesManagedObjectContext(),
            backgroundSessionID: "1",
            path: "/path",
            data: Data(),
            name: "IMG_1234",
            contentType: nil,
            parentFolderID: nil,
            contextID: ContextID(id: "1", context: .course)
        )
    }
}
