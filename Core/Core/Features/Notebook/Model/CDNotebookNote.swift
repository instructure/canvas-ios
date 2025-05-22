//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Foundation

final public class CDNotebookNote: NSManagedObject {
    @NSManaged public var after: String? // used for paging in the query used to fetch this object
    @NSManaged public var before: String? // used for paging in the query used to fetch this object
    @NSManaged public var content: String? // the text of the note
    @NSManaged public var courseID: String
    @NSManaged public var date: Date // the date the note was created
    @NSManaged public var end: NSNumber?
    @NSManaged public var endContainer: String?
    @NSManaged public var endOffset: NSNumber?
    @NSManaged public var id: String
    @NSManaged public var labels: String?
    @NSManaged public var objectType: String
    @NSManaged public var pageID: String
    @NSManaged public var selectedText: String?
    @NSManaged public var start: NSNumber?
    @NSManaged public var startContainer: String?
    @NSManaged public var startOffset: NSNumber?
    @NSManaged public var userID: String?
}

extension String? {
    public var deserializeLabels: [String]? {
        self?.split(separator: ";").map { String($0) }
    }
}

extension Array where Element == String {
    public var serializeLabels: String? {
        self.sorted().joined(separator: ";")
    }
}
