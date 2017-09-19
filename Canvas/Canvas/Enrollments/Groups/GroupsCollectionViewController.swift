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

class GroupsCollectionViewController: FetchedCollectionViewController<Group>, UICollectionViewDelegateFlowLayout {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let session: Session
    let route: (UIViewController, URL)->()
 
    init(session: Session, route: @escaping (UIViewController, URL)->()) throws {
        self.session = session
        self.route = route
        super.init()
        
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        }
        
        let customize: (Enrollment)->() = { [weak self] enrollment in
            let picker = CustomizeEnrollmentViewController(session: session, context: enrollment.contextID)
            let nav = UINavigationController(rootViewController: picker)
            nav.modalPresentationStyle = .formSheet
            
            self?.present(nav, animated: true, completion: nil)
        }
        
        prepare(try Group.favoritesCollection(session), refresher: try Group.refresher(session)) { [weak self] enrollment in
            return EnrollmentCardViewModel(
                session: session,
                enrollment: enrollment,
                showGrades: {_ in },
                customize: { customize(enrollment) },
                takeShortcut: { [weak self] url in if let me = self { route(me, url) } },
                handleError: { [weak self] error in ErrorReporter.reportError(error, from: self) })
        }
        
        
        navigationItem.rightBarButtonItems = [
            editButton
        ]
    }
    
    fileprivate lazy var editButton: UIBarButtonItem = {
        let image = UIImage(named: "icon_cog_small", in: Bundle(for: GroupsCollectionViewController.self), compatibleWith: nil)
        let edit = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(editFavorites(_:)))
        edit.accessibilityLabel = NSLocalizedString("Edit Group List", comment: "Edit group list title")
        edit.accessibilityIdentifier = "editGroupListButton"
        
        return edit
    }()
    
    func editFavorites(_ button: Any?) {
        do {
            let edit = try EditFavoriteEnrollmentsViewController<Group>(session: session, collection: try Enrollment.allGroups(session), refresher: try Group.refresher(session))
            edit.title = NSLocalizedString("Edit Group List", comment: "Edit group list title")
            let nav = UINavigationController(rootViewController: edit)
            nav.modalPresentationStyle = .popover
            nav.popoverPresentationController?.barButtonItem = editButton
            present(nav, animated: true, completion: nil)
        } catch let e as NSError {
            ErrorReporter.reportError(e, from: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let enrollment = collection[indexPath]
        
        guard let tabsURL = URL(string: enrollment.contextID.apiPath/"tabs") else { return print("¯\\_(ツ)_/¯") }
        guard let enrollmentsVC = self.parent else { return print("¯\\_(ツ)_/¯") }
        
        route(enrollmentsVC, tabsURL)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let size = cell.contentView.systemLayoutSizeFitting(collectionView.bounds.size)
            return size
        }
        return .zero
    }
}
