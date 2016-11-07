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
    
    

import UIKit
import EnrollmentKit
import SoPersistent
import TooLegit
import SoLazy

class GroupsCollectionViewController: Group.CollectionViewController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    let session: Session
    let route: (UIViewController, NSURL)->()
 
    init(session: Session, route: (UIViewController, NSURL)->()) throws {
        self.session = session
        self.route = route
        super.init()
        
        let customize: Enrollment->() = { [weak self] enrollment in
            let picker = CustomizeEnrollmentViewController(session: session, context: enrollment.contextID)
            let nav = UINavigationController(rootViewController: picker)
            nav.modalPresentationStyle = .Popover
 
            self?.presentViewController(nav, animated: true, completion: nil)
        }
        
        prepare(try Group.favoritesCollection(session), refresher: try Group.refresher(session)) { enrollment in
            return EnrollmentCardViewModel(
                session: session,
                enrollment: enrollment,
                showGrades: {_ in },
                customize: { customize(enrollment) },
                takeShortcut: { [weak self] url in if let me = self { route(me, url) } },
                handleError: { [weak self] error in if let me = self { error.presentAlertFromViewController(me, alertDismissed: nil) } })
        }
        
        
        navigationItem.rightBarButtonItems = [
            editButton
        ]
    }
    
    private lazy var editButton: UIBarButtonItem = {
        let image = UIImage(named: "icon_cog_small", inBundle: NSBundle(forClass: GroupsCollectionViewController.self), compatibleWithTraitCollection: nil)
        let edit = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .Plain, target: self, action: #selector(editFavorites(_:)))
        edit.accessibilityLabel = NSLocalizedString("Edit Group List", comment: "Edit group list title")
        edit.accessibilityIdentifier = "editGroupListButton"
        
        return edit
    }()
    
    func editFavorites(button: AnyObject?) {
        do {
            let edit = try EditFavoriteEnrollmentsViewController(session: session, collection: try Enrollment.allGroups(session), refresher: try Group.refresher(session))
            edit.title = NSLocalizedString("Edit Group List", comment: "Edit group list title")
            let nav = UINavigationController(rootViewController: edit)
            nav.modalPresentationStyle = .Popover
            nav.popoverPresentationController?.barButtonItem = editButton
            presentViewController(nav, animated: true, completion: nil)
        } catch let e as NSError {
            e.report(alertUserFrom: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let enrollment = collection[indexPath]
        
        guard let tabsURL = NSURL(string: enrollment.contextID.apiPath/"tabs") else { return print("¯\\_(ツ)_/¯") }
        guard let enrollmentsVC = self.parentViewController else { return print("¯\\_(ツ)_/¯") }
        
        route(enrollmentsVC, tabsURL)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
            let size = cell.contentView.systemLayoutSizeFittingSize(collectionView.bounds.size)
            return size
        }
        return CGSizeZero
    }
}
