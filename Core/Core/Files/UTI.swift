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

import Foundation
import MobileCoreServices
import UniformTypeIdentifiers

public struct UTI: Equatable, Hashable {
    static let pagesBundleIdentifier = "com.apple.iwork.pages.pages"
    static let pagesSingleFileIdentifier = "com.apple.iwork.pages.sffpages"
    static let keynoteBundleIdentifier = "com.apple.iwork.keynote.key"
    static let keynoteSingleFileIdentifier = "com.apple.iwork.keynote.sffkey"
    static let numbersBundleIdentifier = "com.apple.iwork.numbers.numbers"
    static let numbersSingleFileIdentifier = "com.apple.iwork.numbers.sffnumbers"

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

    public init?(mime: String) {
        let raw = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mime as CFString, nil)
            .map { $0.takeRetainedValue() }
            .map { $0 as String }

        guard let value = raw, !value.isEmpty, !value.hasPrefix("dyn.") else {
            return nil
        }

        self.rawValue = value
    }

    @available(iOSApplicationExtension 14.0, *)
    public var uttype: UTType? { UTType(rawValue) }

    private init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static func from(extensions: [String]) -> Set<UTI> {
        var utis = Set(extensions.compactMap { UTI(extension: $0) })

        // iWork has types for bundles and single files
        // Make sure the single file equivalent to the bundles are included
        // Bundles are typically present on iCloud Drive whereas singe files are "On My Device"
        if utis.contains(.pagesBundle) { utis.insert(.pagesSingleFile) }
        if utis.contains(.keynoteBundle) { utis.insert(.keynoteSingleFile) }
        if utis.contains(.numbersBundle) { utis.insert(.numbersSingleFile) }

        return utis
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

    public static var fileURL: UTI {
        return UTI(rawValue: kUTTypeFileURL as String)
    }

    public static var pagesBundle: UTI {
        return UTI(rawValue: UTI.pagesBundleIdentifier)
    }

    public static var pagesSingleFile: UTI {
        return UTI(rawValue: UTI.pagesSingleFileIdentifier)
    }

    public static var keynoteBundle: UTI {
        return UTI(rawValue: UTI.keynoteBundleIdentifier)
    }

    public static var keynoteSingleFile: UTI {
        return UTI(rawValue: UTI.keynoteSingleFileIdentifier)
    }

    public static var numbersBundle: UTI {
        return UTI(rawValue: UTI.numbersBundleIdentifier)
    }

    public static var numbersSingleFile: UTI {
        return UTI(rawValue: UTI.numbersSingleFileIdentifier)
    }

    public static var folder: UTI {
        return UTI(rawValue: kUTTypeFolder as String)
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
