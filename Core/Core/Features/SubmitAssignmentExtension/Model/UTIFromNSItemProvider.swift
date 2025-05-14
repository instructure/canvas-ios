//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension NSItemProvider {
    public static var SupportedUTIs: [UTI] = [.image, .fileURL, .any] // in priority order

    public var uti: UTI? {
        let uti = Self.SupportedUTIs.first { hasItemConformingToTypeIdentifier($0.rawValue) }

        if uti == nil {
            RemoteLogger.shared.logError(name: "Unsupported file type", reason: suggestedName)
        }

        return uti
    }
}
