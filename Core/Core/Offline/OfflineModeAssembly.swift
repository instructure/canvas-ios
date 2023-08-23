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

public enum OfflineModeAssembly {
    private static var shared: OfflineModeInteractor?
    private static let synchronizer = DispatchQueue(label: "OfflineModeAssembly-Synchronizer")

    @discardableResult
    public static func make() -> OfflineModeInteractor {
        synchronizer.sync {
            if let shared {
                return shared
            }

            let instance = OfflineModeInteractorLive(availabilityService: NetworkAvailabilityServiceLive(),
                                                     context: AppEnvironment.shared.database.viewContext)
            shared = instance
            return instance
        }
    }

    public static func reset() {
        synchronizer.sync {
            shared = nil
        }
    }

    public static func make(parent: UIViewController) -> OfflineBannerViewModel {
        OfflineBannerViewModel(interactor: make(), parent: parent)
    }

#if DEBUG

    static func mock(_ interactor: OfflineModeInteractor) {
        synchronizer.sync {
            shared = interactor
        }
    }

#endif
}
