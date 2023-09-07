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

/// A value that should be kept reasonably hidden, like a password, token, or key.
///
/// To protect these values from trivial discovery, they are ignored by git, and are obfuscated by a
/// cipher not literally represented in the source code. Therefore dumping the app bundle still won't
/// show the secrets in plain text. It must be possible to discover the secrets, or the app couldn't
/// use them, but it should be non-trivial.
public enum Secret {
    /// The value passed to `PSPDFKit.setLicenseKey`
    case studentPSPDFKitLicense, teacherPSPDFKitLicense

    /// AWS keys values
    case awsAccessKey, awsSecretKey, appArnTemplate
    case customPushDomain

    /// Bugfender key
    case bugfenderKey

    /// The value passed to `Heap.initialize`
    case heapID

    /// Users for UI tests
    case testReadAdmin1, testReadStudent1, testReadStudent2, testReadStudentK5, testReadTeacher1, testReadParent1
    case testLDAPUser, testNotEnrolled, testSAMLUser, testVanityDomainUser
    case dataSeedAdmin

    /// K5 SubAccount ID for Tests
    case k5SubAccountId

    /// The value used for testing that Secret is working properly
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
