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

import CoreData

public class HelpLink: NSManagedObject {
    @NSManaged public var availableToRaw: String?
    @NSManaged public var id: String?
    @NSManaged public var position: Int
    @NSManaged public var subtext: String?
    @NSManaged public var text: String?
    @NSManaged public var url: URL?

    public var availableTo: [HelpLinkEnrollment]? {
        get {
            guard let availableToRaw = availableToRaw else { return nil }
            return availableToRaw.components(separatedBy: ",").compactMap { HelpLinkEnrollment(rawValue: $0) }
        }
        set {
            guard let newValue = newValue else {
                availableToRaw = nil
                return
            }
            availableToRaw = newValue.map { $0.rawValue } .joined(separator: ",") }
    }
}
