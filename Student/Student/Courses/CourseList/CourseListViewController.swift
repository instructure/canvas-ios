//
// Copyright (C) 2018-present Instructure, Inc.
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
import Core

protocol CourseListViewProtocol: ErrorViewController {
    func update(courses: CourseListViewModel)
}

class CourseListViewController: UIViewController, CourseListViewProtocol {
    var presenter: CourseListPresenter?
    var viewModel: CourseListViewModel?

    let gutterWidth: CGFloat = 16
    let shadowMargin: CGFloat = 5
    let cardColumns: CGFloat = 2

    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(CourseListViewController.refreshView(_:)), for: .valueChanged)
        return rc
    }()

    @IBOutlet weak var collectionView: UICollectionView?

    static func create(env: AppEnvironment = .shared) -> CourseListViewController {
        let view = Bundle.loadController(self)
        view.presenter = CourseListPresenter(env: env, view: view)
        return view
    }

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar Setup
        navigationItem.title = NSLocalizedString("All Courses", bundle: .student, comment: "All Courses screen title")

        // Collection View Setup
        collectionView?.refreshControl = refreshControl

        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.pageViewStarted()

        navigationController?.navigationBar.useGlobalNavStyle()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.pageViewEnded()
    }

    @objc
    func refreshView(_ sender: Any) {
        presenter?.refreshRequested()
    }

    func update(courses: CourseListViewModel) {
        self.viewModel = courses

        // check for empty state

        // display courses
        collectionView?.reloadData()
        refreshControl.endRefreshing()
    }

    func itemWasSelected(at indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }

        let courseId = (indexPath.section == CourseListViewSection.current.rawValue)
            ? viewModel.current[indexPath.row].courseID
            : viewModel.past[indexPath.row].courseID

        presenter?.courseWasSelected(courseId, from: self)
    }
}

extension CourseListViewController: ErrorViewController {
    func showError(_ error: Error) {
        print("error:", error.localizedDescription)
    }
}

enum CourseListViewSection: Int {
    case current = 0
    case past = 1
}

extension CourseListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let vm = viewModel else {
            return 0
        }

        return (vm.current.count > 0 || vm.past.count > 0) ? 2 : 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }

        if section == CourseListViewSection.current.rawValue {
            return viewModel.current.count
        }

        return  viewModel.past.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else {
            return UICollectionViewCell(frame: CGRect.zero)
        }

        if indexPath.section == CourseListViewSection.current.rawValue {
            let cell = collectionView.dequeue(CourseListCourseCell.self, for: indexPath)
            let model = viewModel.current[indexPath.row]
            cell.configure(with: model)
            cell.optionsCallback = { [unowned self, model] in
                // TODO:
                //self.delegate?.courseWasSelected(model.courseID)

                // REMOVEDashboardSectionHeaderView
                let alert = UIAlertController(title: "Course Options", message: "Course options was tapped for Id => \(model.courseID)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            return cell
        }

        let cell = collectionView.dequeue(CourseListCourseCell.self, for: indexPath)
        let past = viewModel.past[indexPath.row]
        cell.configure(with: past)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let v = collectionView.dequeue(CourseListSectionHeaderView.self, ofKind: kind, for: indexPath)
            let title = indexPath.section == CourseListViewSection.current.rawValue
                ? ""
                : NSLocalizedString("Past Enrollments", comment: "Past enrollments section title in All Courses screen")
            v.configure(title: title)
            return v
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemWasSelected(at: indexPath)
    }
}

extension CourseListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - ((cardColumns+1) * gutterWidth)) / cardColumns + shadowMargin * 2, height: 173)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = gutterWidth - shadowMargin
        switch CourseListViewSection(rawValue: section) ?? .current {
        case .current:
            return UIEdgeInsets(top: margin, left: margin, bottom: -shadowMargin, right: margin)
        case .past:
            return UIEdgeInsets(top: -shadowMargin, left: margin, bottom: gutterWidth, right: margin)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return gutterWidth - (shadowMargin * 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return gutterWidth - (shadowMargin * 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch CourseListViewSection(rawValue: section) ?? .past {
        case .current:
            return CGSize.zero
        case .past:
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
}
