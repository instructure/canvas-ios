//
// Copyright (C) 2016-present Instructure, Inc.
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
