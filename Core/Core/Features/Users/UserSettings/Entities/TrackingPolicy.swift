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

public enum TrackingPolicy: String {
    case trackingEnabled
    case trackingDisabled
    case askForConsent

    var isPredefined: Bool {
        switch self {
        case .trackingEnabled, .trackingDisabled: true
        case .askForConsent: false
        }
    }

    init?(usageMetrics: String?) {
        guard let usageMetrics else { return nil }

        self = switch usageMetrics {
        case "track_usage": .trackingEnabled
        case "no_track_usage": .trackingDisabled
        case "ask_for_consent": .askForConsent
        default: .trackingDisabled // safest fallback in case backend introduces new values
        }
    }
}
