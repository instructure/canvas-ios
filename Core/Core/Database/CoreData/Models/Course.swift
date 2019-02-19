//
// Copyright (C) 2018-present Instructure, Inc.
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

final public class Course: NSManagedObject, Context {
    public let contextType = ContextType.course

    @NSManaged public var courseCode: String?
    @NSManaged var defaultViewRaw: String?
    @NSManaged public var id: String
    @NSManaged public var imageDownloadURL: URL?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String?
    @NSManaged public var enrollments: Set<Enrollment>?

    public var defaultView: CourseDefaultView? {
        get { return CourseDefaultView(rawValue: defaultViewRaw ?? "") }
        set { defaultViewRaw = newValue?.rawValue }
    }
}

extension Course {
    public var color: UIColor {
        let request = NSFetchRequest<Color>(entityName: String(describing: Color.self))
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Color.canvasContextID), canvasContextID)
        let color = try? managedObjectContext?.fetch(request).first
        return color??.color ?? .named(.ash)
    }
}

extension Course: Scoped {
    public enum ScopeKeys {
        case details(String)
        case all
        case favorites
    }

    public static func scope(forName name: ScopeKeys) -> Scope {
        switch name {
        case let .details(id):
            return .where(#keyPath(Course.id), equals: id)
        case .all:
            return .all(orderBy: #keyPath(Course.name))
        case .favorites:
            return .where(#keyPath(Course.isFavorite), equals: true, orderBy: #keyPath(Course.name))
        }
    }
}
