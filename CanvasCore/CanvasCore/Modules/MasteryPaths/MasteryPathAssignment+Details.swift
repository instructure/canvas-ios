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



extension MasteryPathAssignment {
    public static func observer(_ session: Session, id: String) throws -> ManagedObjectObserver<MasteryPathAssignment> {
        let predicate = NSPredicate(format: "%K == %@", "id", id)
        let context = try session.soEdventurousManagedObjectContext()
        return try ManagedObjectObserver<MasteryPathAssignment>(predicate: predicate, inContext: context)
    }
}

open class MasteryPathAssignmentDetailViewController: CanvasCore.TableViewController {
    fileprivate (set) open var observer: ManagedObjectObserver<MasteryPathAssignment>!
    
    open func prepare<DVM: TableViewCellViewModel>(_ observer: ManagedObjectObserver<MasteryPathAssignment>, detailsFactory: @escaping (MasteryPathAssignment)->[DVM]) where DVM: Equatable {
        self.observer = observer
        let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
        dataSource = CollectionTableViewDataSource(collection: details)
    }
}

