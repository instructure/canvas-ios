//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import AVFoundation
import Foundation

public extension Error {

    var isFrameLoadInterrupted: Bool {
        nsError.domain == "WebKitErrorDomain" && nsError.code == 102
    }

    var isForbidden: Bool {
        nsError.domain == NSError.Constants.domain && nsError.code == HttpError.forbidden
    }

    var isNotFound: Bool {
        nsError.domain == NSError.Constants.domain && nsError.code == HttpError.notFound
    }

    var isBadRequest: Bool {
        nsError.domain == NSError.Constants.domain && nsError.code == HttpError.badRequest
    }

    /// The media file doesn't contain the necessary audio/video track.
    var isSourceTrackMissing: Bool {
        nsError.domain == AVFoundationErrorDomain && nsError.code == AVError.Code.noSourceTrack.rawValue
    }

    var isRefreshTokenInvalid: Bool {
        if let apiError = self as? APIError, case APIError.invalidGrant = apiError {
            return true
        }
        return false
    }

    private var nsError: NSError {
        self as NSError
    }
}
