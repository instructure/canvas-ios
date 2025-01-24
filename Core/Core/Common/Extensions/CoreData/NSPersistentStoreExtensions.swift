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

import CoreData

extension NSPersistentStore {
    public struct InterProcessNotifications {
        /** Listen to this notification to know when the persistent store is written by an external process. */
        public static var didModifyExternally: String {
            appIsExtension ? appDidWriteToPersistentStore : extensionDidWriteToPersistentStore
        }

        /** This notification should be posted when the persistent store is written. */
        public static var didWriteLocally: String {
            appIsExtension ? extensionDidWriteToPersistentStore : appDidWriteToPersistentStore
        }
    }

    private static let appIsExtension = Bundle.main.bundlePath.hasSuffix(".appex")
    private static var extensionDidWriteToPersistentStore = "ExtensionDidWriteToPersistentStore"
    private static var appDidWriteToPersistentStore = "AppDidWriteToPersistentStore"
}
