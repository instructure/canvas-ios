//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreText
import Foundation

/// Registers bundled font files with Core Text so they are available via `Font.custom`.
///
/// Unlike app targets — where fonts listed in `UIAppFonts` (Info.plist) are registered
/// automatically by the OS at launch — fonts inside a Swift Package bundle are not
/// auto-registered. They must be explicitly registered with Core Text using
/// `CTFontManagerRegisterFontsForURL` before any call to `Font.custom` can resolve them.
///
/// Registration is triggered automatically the first time `InstUI.Primitives.fontFamilies`
/// is accessed, because `fontFamilies` is a `static let` whose closure calls this function.
/// Swift guarantees that `static let` closures execute exactly once (thread-safe, lazy),
/// so there is no need for an additional once-only guard here.
enum FontRegistration {

    static func registerFonts() {
        guard let resourceURL = Bundle.module.resourceURL else {
            assertionFailure("InstUI: bundle resource URL not found.")
            return
        }
        guard let enumerator = FileManager.default.enumerator(at: resourceURL, includingPropertiesForKeys: nil) else {
            assertionFailure("InstUI: failed to enumerate font bundle at \(resourceURL).")
            return
        }

        for case let url as URL in enumerator where url.pathExtension == "ttf" || url.pathExtension == "otf" {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
