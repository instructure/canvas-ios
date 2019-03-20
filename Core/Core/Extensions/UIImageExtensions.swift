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
import Foundation

extension UIImage {
    public enum IconName: String, CaseIterable {
        case attendance, collaborations, conferences, todo
        case addFile, addPhoto, addLibrary
        case publish, unpublish
        case warning
    }

    public static func icon(_ name: IconName) -> UIImage {
        return UIImage(named: name.rawValue, in: .core, compatibleWith: nil)!
    }

    /**
     Writes the image to the specified URL

     - Parameter url: The url to write the image to.
     If nil, the image will be written to a temporary directory.
     The URL is assumed to be a directory.

     - Parameter name: The file name to be used. If not provided,
     a sensible default will be generated.

     - Returns: The URL that the image was written to.

     - Note: Directories are created for `url` if they don't already exist.
        Images are written as pngs, therefore, a `png` extension will be given to the name.
        Any file that exists at the destination URL will be overwritten.
     */
    @discardableResult
    public func write(to url: URL? = nil, nameIt name: String? = nil) throws -> URL {
        let directory = url ?? URL.temporaryDirectory.appendingPathComponent("images", isDirectory: true)
        let name = name ?? String(Clock.now.timeIntervalSince1970)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let url = directory.appendingPathComponent(name, isDirectory: false).appendingPathExtension("png")
        guard let data = pngData() else {
            throw NSError.instructureError("Failed to save image")
        }
        if FileManager.default.fileExists(atPath: url.absoluteString) {
            try FileManager.default.removeItem(at: url)
        }
        try data.write(to: url, options: .atomic)
        return url
    }
}
