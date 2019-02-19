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

import Foundation
import MobileCoreServices

public struct UTI: Equatable {
    public let rawValue: String

    public init?(extension: String) {
        let raw = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, `extension` as CFString, nil)
            .map { $0.takeRetainedValue() }
            .map { $0 as String }

        guard let value = raw, !value.isEmpty, !value.hasPrefix("dyn.") else {
            return nil
        }

        self.rawValue = value
    }

    private init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static var any: UTI {
        return UTI(rawValue: kUTTypeItem as String)
    }

    public static var video: UTI {
        return UTI(rawValue: kUTTypeMovie as String)
    }

    public static var audio: UTI {
        return UTI(rawValue: kUTTypeAudio as String)
    }

    public static var image: UTI {
        return UTI(rawValue: kUTTypeImage as String)
    }

    public static var text: UTI {
        return UTI(rawValue: kUTTypeText as String)
    }

    public static var url: UTI {
        return UTI(rawValue: kUTTypeURL as String)
    }

    public var isVideo: Bool {
        return UTTypeConformsTo(rawValue as CFString, kUTTypeMovie)
    }

    public var isImage: Bool {
        return UTTypeConformsTo(rawValue as CFString, kUTTypeImage)
    }

    public var isAudio: Bool {
        return UTTypeConformsTo(rawValue as CFString, kUTTypeAudio)
    }

    public var isAny: Bool {
        return UTTypeConformsTo(rawValue as CFString, kUTTypeItem)
    }
}
