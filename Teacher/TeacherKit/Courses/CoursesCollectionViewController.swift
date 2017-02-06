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
import TooLegit
import SoIconic
import SoPretty

private func courseVM(_ course: Course, session: Session, presenter: UIViewController?) -> CourseViewModel {

    let contextID = course.contextID

    return CourseViewModel(enrollment: course,
       customize: { [weak presenter] button in
        let customize = CustomizeEnrollmentViewController(session: session, context: contextID)
        let nav = UINavigationController(rootViewController: customize)
        
        nav.modalPresentationStyle = .popover
        nav.popoverPresentationController?.sourceView = button
        nav.popoverPresentationController?.sourceRect = button.bounds
        nav.preferredContentSize = CGSize(width: 320, height: 240)
        
        presenter?.present(nav, animated: true, completion: nil)
    }, makeAnAnnouncement: { [weak presenter] in
        
    })
}


private let coursesTitle = NSLocalizedString("Courses", comment: "Courses view title and nav button")
class CoursesCollectionViewController: Course.CollectionViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    static func tab() throws -> UIViewController {
        let nav = UINavigationController(rootViewController: try CoursesCollectionViewController.courses())
        nav.navigationBar.barStyle = .black
        nav.tabBarItem.title = coursesTitle
        nav.tabBarItem.image = .icon(.course)
        nav.tabBarItem.selectedImage = .icon(.course, filled: true)
        return nav
    }
    
    private static func courses() throws -> CoursesCollectionViewController {
        let session = TEnv.current.session
        let refresher = try Course.refresher(session)
        let collection = try Course.favoritesCollection(session)
        
        let me = CoursesCollectionViewController()
        me.title = coursesTitle
        
        me.prepare(collection, refresher: refresher) { [weak me] course in
            return courseVM(course, session: session, presenter: me)
        }
        
        return me
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = collection[indexPath]
        let url = URL(string: "/courses/\(course.id)")!

        TEnv.current.router.route(to: url, from: self)
    }
}
