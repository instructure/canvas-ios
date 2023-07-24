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

import Foundation

public enum NetworkAvailabilityStatus {
    case connected(ConnectionType)
    case disconnected

    public enum ConnectionType: String {
        case cellular, wifi
    }

    var isConnected: Bool {
        switch self {
        case .connected: return true
        case .disconnected: return false
        }
    }

    var isConnectedViaWifi: Bool {
        switch self {
        case let .connected(connectionType): return connectionType == .wifi
        case .disconnected: return false
        }
    }
}

extension NetworkAvailabilityStatus: Equatable {
    public static func == (lhs: NetworkAvailabilityStatus, rhs: NetworkAvailabilityStatus) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected): return true
        case let (.connected(lhsType), .connected(rhsType)): return lhsType == rhsType
        default: return false
        }
    }
}
