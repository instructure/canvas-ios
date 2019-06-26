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
        case attendance, cameraSolid, collaborations, conferences
        case dashboardCustomSolid, todo, todoSolid
        case addAudioLine, addCameraLine, addDocumentLine, addImageLine, addVideoCameraLine
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
        let url = directory.appendingPathComponent(name, isDirectory: false).appendingPathExtension("jpg")
        guard let data = jpegData(compressionQuality: 0.8) else {
            throw NSError.instructureError(NSLocalizedString("Failed to save image", bundle: .core, comment: ""))
        }
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try data.write(to: url)
        return url
    }

    public func normalize() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }
}
