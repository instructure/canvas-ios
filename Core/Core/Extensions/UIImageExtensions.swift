//
// Copyright (C) 2018-present Instructure, Inc.
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

import UIKit

extension UIImage {
    public enum IconName: String, CaseIterable {
        case attendance, collaborations, conferences, todo, addFile, addPhoto, addLibrary, warning
    }

    public static func icon(_ name: IconName) -> UIImage {
        return UIImage(named: name.rawValue, in: .core, compatibleWith: nil)!
    }

    public func temporarilyStoreForSubmission() throws -> FileInfo? {
        let imageSaveName = "\(String(describing: Clock.now.timeIntervalSince1970))-submission.png"
        guard var url: URL = try? URL.temporarySubmissionDirectoryPath() else { return nil }
        guard let data: Data =  self.pngData() else { return nil }
        url.appendPathComponent(imageSaveName)
        try data.write(to: url, options: Data.WritingOptions.atomicWrite)
        return FileInfo(url: url, size: Int64(data.count))
    }
}
