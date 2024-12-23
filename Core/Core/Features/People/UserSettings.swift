//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import CoreData

public final class UserSettings: NSManagedObject, WriteableModel {
    public typealias JSON = APIUserSettings

    @NSManaged public var manualMarkAsRead: Bool
    @NSManaged public var collapseGlobalNav: Bool
    @NSManaged public var hideDashcardColorOverlays: Bool
    @NSManaged public var commentLibrarySuggestionsEnabled: Bool

    public static func save(_ item: APIUserSettings, in context: NSManagedObjectContext) -> UserSettings {
        let model: UserSettings = context.fetch(nil).first ?? context.insert()
        model.manualMarkAsRead = item.manual_mark_as_read
        model.collapseGlobalNav = item.collapse_global_nav
        model.hideDashcardColorOverlays = item.hide_dashcard_color_overlays
        model.commentLibrarySuggestionsEnabled = item.comment_library_suggestions_enabled
        return model
    }
}
