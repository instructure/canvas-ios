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
    
    





import ReactiveSwift
import ReactiveCocoa


func colorfulFavoriteViewModel(_ enrollment: Enrollment) -> ColorfulViewModel {
    let vm = ColorfulViewModel(features: .subtitle)
    vm.title.value = enrollment.name
    vm.color <~ enrollment.color.map { $0 ?? .prettyGray() }
    vm.subtitle.value = enrollment.shortName
    
    let image = UIImage.icon(.star, filled: enrollment.isFavorite)
    vm.accessoryView.value = UIImageView(image: image)
    return vm
}

open class EditFavoriteEnrollmentsViewController<T where T: Enrollment>: TableViewController {
    let collection: FetchedCollection<T>
    let session: Session
    
    public init(session: Session, collection: FetchedCollection<T>, refresher: Refresher) throws {
        self.session = session
        self.collection = collection
        super.init()

        self.dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: colorfulFavoriteViewModel)
        self.refresher = refresher

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss(_:)))

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    func dismiss(_ button: AnyObject?) {
        dismiss(animated: true, completion: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"No storyboards!"
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let enrollment = collection[indexPath]
        
        enrollment.markAsFavorite(!enrollment.isFavorite, session: session).startWithFailed { [weak self] error in
            ErrorReporter.reportError(error, from: self)
        }
    }
}

extension Enrollment {
    public static func allCourses(_ session: Session) throws -> FetchedCollection<Course> {
        let context = try session.enrollmentManagedObjectContext()
        return try FetchedCollection(frc:
            context.fetchedResults(nil, sortDescriptors: ["isFavorite".descending, "name".ascending, "id".ascending], sectionNameKeypath: "faves")
        )
    }
    
    public static func allGroups(_ session: Session) throws -> FetchedCollection<Group> {
        let context = try session.enrollmentManagedObjectContext()
        return try FetchedCollection(frc:
            context.fetchedResults(nil, sortDescriptors: ["isFavorite".descending, "name".ascending, "id".ascending], sectionNameKeypath: "faves")
        )
    }
}
