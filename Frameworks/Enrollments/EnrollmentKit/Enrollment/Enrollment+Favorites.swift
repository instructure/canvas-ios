//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import SoPersistent
import SoPretty
import SoLazy
import TooLegit

func colorfulFavoriteViewModel(enrollment: Enrollment) -> ColorfulViewModel {
    let vm = ColorfulViewModel(style: .Subtitle)
    vm.title.value = enrollment.name
    vm.color.value = enrollment.color ?? UIColor.prettyGray()
    vm.detail.value = enrollment.shortName
    
    let imageName = enrollment.isFavorite ? "icon_favorite_fill" : "icon_favorite"
    
    vm.accessoryView.value = UIImageView(image: UIImage(named: imageName, inBundle: NSBundle(forClass: EditFavoriteEnrollmentsViewController.self), compatibleWithTraitCollection: nil))
    return vm
}

public class EditFavoriteEnrollmentsViewController: TableViewController {
    let collection: FetchedCollection<Enrollment>
    let session: Session
    
    public init(session: Session, collection: FetchedCollection<Enrollment>, refresher: Refresher) throws {
        self.session = session
        self.collection = collection
        super.init()
        
        self.dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: colorfulFavoriteViewModel)
        self.refresher = refresher
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(dismiss(_:)))
    }
    
    func dismiss(button: AnyObject?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        ❨╯°□°❩╯⌢"No storyboards!"
    }
    
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let enrollment = collection[indexPath]
        
        enrollment.markAsFavorite(!enrollment.isFavorite, session: session).startWithFailed { [weak self] error in
            guard let me = self else { return }
            error.presentAlertFromViewController(me)
        }
    }
}

extension Enrollment {
    public static func allCourses(session: Session) throws -> FetchedCollection<Enrollment> {
        let frc = Course.fetchedResults(nil, sortDescriptors: ["isFavorite".descending, "name".ascending, "id".ascending], sectionNameKeypath: "faves", inContext: try session.enrollmentManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }
    
    public static func allGroups(session: Session) throws -> FetchedCollection<Enrollment> {
        let frc = Group.fetchedResults(nil, sortDescriptors: ["isFavorite".descending, "name".ascending, "id".ascending], sectionNameKeypath: "faves", inContext: try session.enrollmentManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }
}
