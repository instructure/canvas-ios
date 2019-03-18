//
// Copyright (C) 2019-present Instructure, Inc.
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

public class NewSubmission: NSManagedObject {
    @NSManaged public var assignment: Assignment?
    @NSManaged public var files: Set<File>?

    public var failed: Bool {
        return files?.first { $0.uploadError != nil } != nil
    }

    public var readyToSubmit: Bool {
        return !failed && files?.isEmpty == false && files?.allSatisfy { $0.isUploaded } == true
    }
}
