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
import ReactiveCocoa
import SoLazy

class EnrollmentCollectionViewModel: Enrollment.ViewModel, CollectionViewCellViewModel {
    
    var customize: ()->()
    
    init(enrollment: Enrollment?, customize: ()->()) {
        self.customize = customize
        super.init(enrollment: enrollment)
    }
    
    static func viewDidLoad(collectionView: UICollectionView) {
        collectionView.registerNib(UINib(nibName: "EnrollmentCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EnrollmentCell")
    }
    
    static var layout: UICollectionViewLayout {
        return PrettyCardsLayout()
    }
    
    func cellForCollectionView(collectionView: UICollectionView, indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EnrollmentCell", forIndexPath: indexPath) as? EnrollmentCollectionViewCell else { ❨╯°□°❩╯⌢"Get your cells straightened out, everyone" }

        cell.titleLabel.text = enrollment.value?.name
        cell.gradeLabel.text = [enrollment.value?.visibleGrade, enrollment.value?.visibleScore]
            .flatMap { $0 }
            .joinWithSeparator("  ")
        
        
        cell.enrollment <~ enrollment.producer
        cell.customize = customize
        
        return cell
    }

    convenience init(enrollment: Enrollment, session: Session, viewController: UIViewController) {
        self.init(enrollment: enrollment) { [weak viewController] in
            
            let picker = CustomizeEnrollmentViewController(session: session, context: enrollment.contextID)
            
            viewController?.presentViewController(UINavigationController(rootViewController: picker), animated: true, completion: nil)
        }
    }
}

class CoursesCollectionViewController: Course.CollectionViewController {
    let session: Session
    
    init(session: Session) throws {
        self.session = session
        super.init()
        
        try prepare(Course.favoritesCollection(session), refresher: Course.refresher(session)) { [unowned self]enrollment in
            return EnrollmentCollectionViewModel(enrollment: enrollment, session: session, viewController: self)
        }
        
        let editFaves = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(editFaves(_:)))
        navigationItem.rightBarButtonItem = editFaves
    }
    
    func editFaves(button: AnyObject?) {
        do {
            let edit = try EditFavoriteEnrollmentsViewController(session: session, collection: try Enrollment.allCourses(session), refresher: try Course.refresher(session))
            let nav = UINavigationController(rootViewController: edit)
            presentViewController(nav, animated: true, completion: nil)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let c = collection[indexPath]
        
        do {
            let tabs = try TabsTableViewController(session: session, contextID: c.contextID)
            self.navigationController?.pushViewController(tabs, animated: true)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
}


class GroupsCollectionViewController: Group.CollectionViewController {
    let session: Session
    
    init(session: Session) throws {
        self.session = session
        super.init()
        
        try prepare(Group.favoritesCollection(session), refresher: Group.refresher(session)) { [unowned self]enrollment in
            return EnrollmentCollectionViewModel(enrollment: enrollment, session: session, viewController: self)
        }
        
        
        let editFaves = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(editFaves(_:)))
        navigationItem.rightBarButtonItem = editFaves
    }
    
    func editFaves(button: AnyObject?) {
        do {
            let edit = try EditFavoriteEnrollmentsViewController(session: session, collection: try Enrollment.allGroups(session), refresher: try Group.refresher(session))
            let nav = UINavigationController(rootViewController: edit)
            presentViewController(nav, animated: true, completion: nil)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let g = collection[indexPath]
        
        do {
            let tabs = try TabsTableViewController(session: session, contextID: g.contextID)
            self.navigationController?.pushViewController(tabs, animated: true)
        } catch let e as NSError {
            e.presentAlertFromViewController(self)
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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = choices[indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        navigationController?.pushViewController(choices[indexPath.row].viewControllerPlz(), animated: true)
    }
}
