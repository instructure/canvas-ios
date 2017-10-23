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

import Foundation
import CanvasCore

extension Session {
    public func logFilePath() -> URL? {
        let files = try! FileManager.default.contentsOfDirectory(at: logDirectoryURL, includingPropertiesForKeys: [URLResourceKey.contentModificationDateKey], options: .skipsHiddenFiles).sorted(by: { file1URL, file2URL -> Bool in
            do {
                let file1URLModifiedDate = try file1URL.resourceValues(forKeys: [URLResourceKey.contentModificationDateKey]).contentModificationDate

                let file2URLModifiedDate = try file2URL.resourceValues(forKeys: [URLResourceKey.contentModificationDateKey]).contentModificationDate

                if let date1 = file1URLModifiedDate, let date2 = file2URLModifiedDate {
                    return date1 < date2
                }
            } catch {
                return false
            }
            return false
        })

        return files.first
    }
}
