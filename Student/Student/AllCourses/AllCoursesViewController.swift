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

protocol AllCoursesViewProtocol: class {
    func updateDisplay(_ viewModel: AllCoursesViewModel)
}

class AllCoursesViewController: UIViewController, AllCoursesViewProtocol {
    var presenter: AllCoursesPresenterProtocol?
    var viewModel: AllCoursesViewModel?

    let gutterWidth: CGFloat = 16
    let shadowMargin: CGFloat = 5
    let cardColumns: CGFloat = 2

    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(AllCoursesViewController.refreshView(_:)), for: .valueChanged)
        return rc
    }()

    @IBOutlet weak var collectionView: UICollectionView!

    static func create(env: AppEnvironment = .shared) -> AllCoursesViewController {
        let storyboard = UIStoryboard(name: "AllCoursesViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "vc") as? AllCoursesViewController else {
            fatalError("AllCoursesViewController should come from the storyboard in: \(#function)")
        }
        vc.presenter = AllCoursesPresenter(env: env, view: vc)
        return vc
    }

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar Setup
        navigationItem.title = NSLocalizedString("All Courses", comment: "All Courses screen title")

        // Collection View Setup
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl

        presenter?.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.pageViewStarted()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.pageViewEnded()
    }

    @objc
    func refreshView(_ sender: Any) {
        presenter?.refreshRequested()
    }

    func updateDisplay(_ viewModel: AllCoursesViewModel) {
        self.viewModel = viewModel

        // check for empty state

        // update header
        navigationController?.navigationBar.barTintColor = viewModel.navBackgroundColor
        navigationController?.navigationBar.tintColor = viewModel.navTextColor.ensureContrast(against: viewModel.navBackgroundColor)
        navigationController?.navigationBar.barStyle = viewModel.navBackgroundColor.luminance < 0.5 ? .black : .default

        // display courses
        collectionView.reloadData()
        refreshControl.endRefreshing()
    }

    func itemWasSelected(at indexPath: IndexPath) {
        guard let viewModel = viewModel else {
            return
        }

        var alertTitle: String
        var itemId: String
        var itemTitle: String
        if indexPath.section == AllCoursesViewSection.current.rawValue {
            let course = viewModel.current[indexPath.row]
            alertTitle = "Course"
            itemTitle = course.title
            itemId = course.courseID

            //delegate?.courseWasSelected(itemId)
        } else {
            let past = viewModel.past[indexPath.row]
            alertTitle = "Past Course"
            itemTitle = past.title
            itemId = past.courseID

            //delegate?.courseWasSelected(itemId)
        }

        // REMOVE
        let alert = UIAlertController(title: "\(alertTitle) Selected",
            message: "\(alertTitle) Id => \(itemId) and title => \(itemTitle) was selected. See line: \(#line) in \(#file)",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension AllCoursesViewController: ErrorViewController {
    func showError(_ error: Error) {
        print("error:", error.localizedDescription)
    }
}

enum AllCoursesViewSection: Int {
    case current = 0
    case past = 1
}

extension AllCoursesViewController: UICollectionViewDataSource {
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

        if section == AllCoursesViewSection.current.rawValue {
            return viewModel.current.count
        }

        return  viewModel.past.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else {
            return UICollectionViewCell(frame: CGRect.zero)
        }

        if indexPath.section == AllCoursesViewSection.current.rawValue {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseCard", for: indexPath) as? AllCoursesCourseCell else {
                fatalError("dequeueReusableCell for courseCard must return AllCoursesCourseCell")
            }
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

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseCard", for: indexPath) as? AllCoursesCourseCell else {
            fatalError("dequeueReusableCell for courseCard should return AllCoursesCourseCell in \(#function)")
        }
        let past = viewModel.past[indexPath.row]
        cell.configure(with: past)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                          withReuseIdentifier: "header",
                                                                          for: indexPath) as? AllCoursesSectionHeaderView else {
                fatalError("dequeueReusableSupplementaryView for header must return AllCoursesSectionHeaderView in \(#function)")
            }

            var title: String
            if indexPath.section == AllCoursesViewSection.current.rawValue {
                title = ""
            } else {
                title = NSLocalizedString("Past Enrollments", comment: "Past enrollments section title in All Courses screen")
            }

            v.configure(title: title)
            return v
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemWasSelected(at: indexPath)
    }
}

extension AllCoursesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - ((cardColumns+1) * gutterWidth)) / cardColumns + shadowMargin * 2, height: 173)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = gutterWidth - shadowMargin
        switch AllCoursesViewSection(rawValue: section) ?? .current {
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
        switch AllCoursesViewSection(rawValue: section) ?? .past {
        case .current:
            return CGSize.zero
        case .past:
            return CGSize(width: collectionView.bounds.width, height: 50)
        }
    }
}
