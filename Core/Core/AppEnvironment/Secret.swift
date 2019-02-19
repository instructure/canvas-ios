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

/// A value that should be kept reasonably hidden, like a password, token, or key.
///
/// To protect these values from trivial discovery, they are ignored by git, and are obfuscated by a
/// cipher not literally represented in the source code. Therefore dumping the app bundle still won't
/// show the secrets in plain text. It must be possible to discover the secrets, or the app couldn't
/// use them, but it should be non-trivial.
public enum Secret {
    /// The Canvas API token used to create resources for UI tests.
    case dataSeedingAdminToken

    /// The value passed to `PSPDFKit.setLicenseKey` for the student app.
    case studentPSPDFKitLicense

    /// The value passed to `PSPDFKit.setLicenseKey` for the teacher app.
    case teacherPSPDFKitLicense

    /// The value used for testing that Secret is working properly.
    case testSecret

    public var string: String? {
        guard let data = NSDataAsset(name: String(describing: self), bundle: .core)?.data else { return nil }
        let mixer = [UInt8]("\(String(describing: self))+\(Bundle.core.bundleIdentifier ?? "")".utf8)
        var bytes = data.enumerated().map { (offset: Int, element: UInt8) -> UInt8 in
            return element ^ mixer[offset % mixer.count]
        }
        bytes.removeLast(Int(bytes.removeLast()))
        return String(bytes: bytes, encoding: .utf8)
    }
}
