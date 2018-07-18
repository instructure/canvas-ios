//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData


public class MasteryPathsItem: ModuleItem {
    @NSManaged internal (set) public var moduleItemID: String
    @NSManaged internal (set) public var selectedSetID: String?
    @NSManaged internal (set) public var assignmentSets: NSSet

    func addAssignmentSetObject(object: MasteryPathAssignmentSet) {
        let sets = self.mutableSetValue(forKey: "assignmentSets")
        sets.add(object)
    }

    func removeAssignmentSetObject(object: MasteryPathAssignmentSet) {
        let sets = self.mutableSetValue(forKey: "assignmentSets")
        sets.remove(object)
    }
}
