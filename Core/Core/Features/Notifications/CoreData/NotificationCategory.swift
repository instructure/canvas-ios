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

public class NotificationCategory: NSManagedObject {
    @NSManaged public var channelID: String
    @NSManaged public var category: String
    @NSManaged public var frequencyRaw: String
    @NSManaged public var notificationsRaw: String

    public var frequency: NotificationFrequency {
        get { return NotificationFrequency(rawValue: frequencyRaw) ?? .never }
        set { frequencyRaw = newValue.rawValue }
    }

    public var notifications: [String] {
        get { return notificationsRaw.components(separatedBy: ",") }
        set { notificationsRaw = newValue.joined(separator: ",") }
    }
}
