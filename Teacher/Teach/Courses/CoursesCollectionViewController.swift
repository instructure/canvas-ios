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
    static func tab(_ session: Session, route: @escaping RouteAction) throws -> UIViewController {
        let nav = UINavigationController(rootViewController: try CoursesCollectionViewController(session: session, route: route))
        nav.tabBarItem.title = coursesTitle
        nav.tabBarItem.image = .icon(.course)
        nav.tabBarItem.selectedImage = .icon(.course, filled: true)
        return nav
    }
    
    let route: RouteAction
    
    init(session: Session, route: @escaping RouteAction) throws {
        self.route = route
        super.init()
        
        navigationItem.title = coursesTitle
        prepare(try Course.favoritesCollection(session), refresher: try Course.refresher(session)) { [weak self] course in
            return courseVM(course, session: session, presenter: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let course = collection[indexPath]
        
        do {
            try route(self, URL(string: "/courses/\(course.id)")!)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
}
