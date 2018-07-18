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
import ReactiveSwift
import CanvasCore

extension Student {
    public static func predicate(withStudentID studentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", studentID)
    }

    public static func observer(_ session: Session, studentID: String) throws -> ManagedObjectObserver<Student> {
        let pred = predicate(withStudentID: studentID)
        let context = try session.airwolfManagedObjectContext()
        return try ManagedObjectObserver<Student>(predicate: pred, inContext: context)
    }
}
