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
    
    

import UIKit
import TooLegit
import EnrollmentKit
import SoPretty
import DoNotShipThis
import SoPersistent
import ReactiveSwift
import SoLazy

class EnrollmentCollectionViewModel: EnrollmentViewModel, CollectionViewCellViewModel {
    
    var customize: ()->()
    
    init(enrollment: Enrollment?, customize: @escaping ()->()) {
        self.customize = customize
        super.init(enrollment: enrollment)
    }
    
    static func viewDidLoad(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "EnrollmentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EnrollmentCell")
    }
    
    static var layout: UICollectionViewLayout {
        return PrettyCardsLayout()
    }
    
    func cellForCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EnrollmentCell", for: indexPath) as? EnrollmentCollectionViewCell else { ❨╯°□°❩╯⌢"Get your cells straightened out, everyone" }

        cell.titleLabel.text = enrollment.value?.name
        cell.gradeLabel.text = [enrollment.value?.visibleGrade, enrollment.value?.visibleScore]
            .flatMap { $0 }
            .joined(separator: "  ")
        
        
        cell.enrollment <~ enrollment.producer
        cell.customize = customize
        
        return cell
    }

    convenience init(enrollment: Enrollment, session: Session, viewController: UIViewController) {
        self.init(enrollment: enrollment) { [weak viewController] in
            
            let picker = CustomizeEnrollmentViewController(session: session, context: enrollment.contextID)
            
            viewController?.present(UINavigationController(rootViewController: picker), animated: true, completion: nil)
        }
    }
}

class CoursesCollectionViewController: FetchedCollectionViewController<Course> {
    let session: Session
    
    init(session: Session) throws {
        self.session = session
        super.init()
        
        try prepare(Course.favoritesCollection(session), refresher: Course.refresher(session)) { [unowned self] enrollment in
            return EnrollmentCollectionViewModel(enrollment: enrollment, session: session, viewController: self)
        }
        
        let editFaves = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editFaves(_:)))
        navigationItem.rightBarButtonItem = editFaves
    }
    
    func editFaves(_ button: AnyObject?) {
        do {
            let edit = try EditFavoriteEnrollmentsViewController(session: session, collection: try Enrollment.allCourses(session), refresher: try Course.refresher(session))
            let nav = UINavigationController(rootViewController: edit)
            present(nav, animated: true, completion: nil)
        } catch let e as NSError {
            ErrorReporter.reportError(e, from: self)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let c = collection[indexPath]
        
        do {
            let tabs = try TabsTableViewController(session: session, contextID: c.contextID)
            self.navigationController?.pushViewController(tabs, animated: true)
        } catch let e as NSError {
            ErrorReporter.reportError(e, from: self)
        }
    }
}


class GroupsCollectionViewController: FetchedCollectionViewController<Group> {
    let session: Session
    
    init(session: Session) throws {
        self.session = session
        super.init()
        
        try prepare(Group.favoritesCollection(session), refresher: Group.refresher(session)) { [unowned self]enrollment in
            return EnrollmentCollectionViewModel(enrollment: enrollment, session: session, viewController: self)
        }
        
        
        let editFaves = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editFaves(_:)))
        navigationItem.rightBarButtonItem = editFaves
    }
    
    func editFaves(_ button: AnyObject?) {
        do {
            let edit = try EditFavoriteEnrollmentsViewController(session: session, collection: try Enrollment.allGroups(session), refresher: try Group.refresher(session))
            let nav = UINavigationController(rootViewController: edit)
            present(nav, animated: true, completion: nil)
        } catch let e as NSError {
            ErrorReporter.reportError(e, from: self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let g = collection[indexPath]
        
        do {
            let tabs = try TabsTableViewController(session: session, contextID: g.contextID)
            self.navigationController?.pushViewController(tabs, animated: true)
        } catch let e as NSError {
            ErrorReporter.reportError(e, from: self)
        }
    }
}


class IntroViewController: UITableViewController {
    struct Choice {
        let name: String
        let viewControllerPlz: ()->UIViewController
    }
    
    let choices = [
        Choice(name: "Art Artimus") {
            let session = Session.art
            
            return PagedViewController(pages: [
                ControllerPage(title: "Courses", controller: try! CoursesCollectionViewController(session: session)),
                ControllerPage(title: "Groups", controller: try! GroupsCollectionViewController(session: session))
            ])
        },
        Choice(name: "Walter White") {
            let session = Session.parentTest

            return PagedViewController(pages: [
                ControllerPage(title: "Courses", controller: try! CoursesCollectionViewController(session: session)),
                ControllerPage(title: "Groups", controller: try! GroupsCollectionViewController(session: session))
                ])
        }
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = choices[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(choices[indexPath.row].viewControllerPlz(), animated: true)
    }
}
