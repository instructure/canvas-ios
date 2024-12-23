//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit

extension UIImage {
    /**
     Writes the image to the specified URL

     - Parameter url: The url to write the image to.
     If nil, the image will be written to a temporary directory.
     The URL is assumed to be a directory.

     - Parameter name: The file name to be used. If not provided,
     a sensible default will be generated.

     - Returns: The URL that the image was written to.

     - Note: Directories are created for `url` if they don't already exist.
        Images are written as jpegs, therefore, a `jpg` extension will be given to the name.
        Any file that exists at the destination URL will be overwritten.
     */
    @discardableResult
    public func write(to url: URL? = nil, nameIt name: String? = nil) throws -> URL {
        let directory = url ?? URL.Directories.temporary.appendingPathComponent("images", isDirectory: true)
        let name = name ?? String(Clock.now.timeIntervalSince1970)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        let url = directory.appendingPathComponent(name, isDirectory: false).appendingPathExtension("jpg")
        guard let data = jpegData(compressionQuality: 0.8) else {
            throw NSError.instructureError(String(localized: "Failed to save image", bundle: .core))
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

    public func scaleTo(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? self
    }

    public var asDataUrl: URL? {
        guard let data = pngData() else { return nil }
        return URL(string: "data:image/png;base64,\(data.base64EncodedString())")
    }
}
