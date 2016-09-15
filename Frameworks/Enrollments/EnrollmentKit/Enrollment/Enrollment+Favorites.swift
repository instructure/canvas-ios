//
//  Enrollment+Favorites.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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