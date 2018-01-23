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
    
    

import CanvasCore
import ReactiveSwift
import Cartography

func courseCardViewModel(_ enrollment: Enrollment, session: Session, viewController:
    CoursesCollectionViewController?, routeGrades: @escaping (URL) -> ()) -> EnrollmentCardViewModel {
    
    let gradesURL = URL(string: enrollment.contextID.htmlPath / "grades")!
    
    let vm = EnrollmentCardViewModel(session: session, enrollment: enrollment, showGrades: {
        routeGrades(gradesURL)
    }, customize: { [weak viewController] in
        let picker = CustomizeEnrollmentViewController(session: session, context: enrollment.contextID)
        let nav = UINavigationController(rootViewController: picker)
        nav.modalPresentationStyle = .formSheet
        
        viewController?.present(nav, animated: true, completion: nil)
        },
       takeShortcut: { [weak viewController] url in if let me = viewController { me.route(me, url) } },
       handleError: { [weak viewController] error in ErrorReporter.reportError(error, from: viewController) })
    
    if let courses = viewController {
        vm.showingGrades <~ courses.showingGrades
    }

    return vm
}

open class CoursesCollectionViewController: FetchedCollectionViewController<Course>, UICollectionViewDelegateFlowLayout {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let session: Session
    let route: (UIViewController, URL)->()
    var favoritesCountObserver: ManagedObjectCountObserver<Course>?
    var currentFavoritesCount: Int?
    
    var showingGrades = MutableProperty<Bool>(false)
    
    public init(session: Session, route: @escaping (UIViewController, URL)->()) throws {
        self.session = session
        self.route = route
        super.init()

        let context = try session.enrollmentManagedObjectContext()
        
        let refresher = try Course.refresher(session)
        refresher.refreshingBegan.observeValues {
            // Let's invalidate all the tabs so that they get refreshed too
            if let courses: [Course] = try? context.findAll() {
                for course in courses {
                    let cacheKey = Tab.cacheKey(context, [course.contextID.description])
                    session.refreshScope.invalidateCache(cacheKey)
                }
            }
        }
        
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        }
        
        let favorites = NSPredicate(format: "%K == YES", "isFavorite")
        self.favoritesCountObserver = ManagedObjectCountObserver<Course>(predicate: favorites, inContext: context) { [weak self] (courseFavoriteCount) in
            
            defer { self?.currentFavoritesCount = courseFavoriteCount }
            
            guard let me = self else { return }
            
            // Don't reset the collection if it's already of the same type
            if let previous = me.currentFavoritesCount {
                if previous > 0 && courseFavoriteCount > 0   { return }
                if previous == 0 && courseFavoriteCount == 0 { return }
            }
            
            var collection: FetchedCollection<Course>?
            
            switch courseFavoriteCount {
                case 0: collection = try? Course.allCoursesCollection(session)
                default: collection = try? Course.favoritesCollection(session)
            }
            
            guard let c = collection else { return }
            
            self?.prepare(c, refresher: refresher) { enrollment in
                courseCardViewModel(enrollment, session: session, viewController: self) { gradesURL in
                    guard let me = self else { return }
                    route(me, gradesURL)
                }
            }
        }
        
        updateNavigationBarItems()
    }
    
    func editFavorites(_ button: Any?) {
        do {
            let edit = try EditFavoriteEnrollmentsViewController<Course>(session: session, collection: try Enrollment.allCourses(session), refresher: try Course.refresher(session))
            edit.title = NSLocalizedString("Edit Course List", comment: "Edit course list title")
            let nav = UINavigationController(rootViewController: edit)
            nav.modalPresentationStyle = .popover
            nav.popoverPresentationController?.barButtonItem = editButton
            present(nav, animated: true, completion: nil)
        } catch let e as NSError {
            ErrorReporter.reportError(e, from: self)
        }
    }
    
    fileprivate lazy var editButton: UIBarButtonItem = {
        let image = UIImage.icon(.settings)
        let edit = UIBarButtonItem(image: image, landscapeImagePhone: nil, style: .plain, target: self, action: #selector(editFavorites(_:)))
        edit.accessibilityLabel = NSLocalizedString("Edit Course List", comment: "Edit course list title")
        edit.accessibilityIdentifier = "editCourseListButton"
        return edit
    }()
    
    // Creating new buttons each time an update was required didn't work, so I had to cache the button
    var button: UIBarButtonItem?
    
    func toggleGradesButton() -> UIBarButtonItem {
        let image: UIImage?
        let label: String
        
        if showingGrades.value {
            label = NSLocalizedString("Hide Grades", comment: "Accessibility label for toggling grades to hidden")
            image = UIImage(named: "icon_grades_fill_small", in: Bundle(for: CoursesCollectionViewController.self), compatibleWith: nil)
        } else {
            label = NSLocalizedString("Show Grades", comment: "Accessibility label for toggling grades to visible")
            image = UIImage(named: "icon_grades_small", in: Bundle(for: CoursesCollectionViewController.self), compatibleWith: nil)
        }
        
        let button = self.button ?? UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(toggleGrades(_:)))
        button.image = image
        button.accessibilityLabel = label
        self.button = button
        return button
    }
    
    func toggleGrades(_ sender: Any) {
        showingGrades.value = !showingGrades.value
        updateNavigationBarItems()
    }
    
    func updateNavigationBarItems() {
        navigationItem.rightBarButtonItems = [
            editButton,
            toggleGradesButton(),
        ]
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? EnrollmentCardCell)?.updateA11y()
    }
}
