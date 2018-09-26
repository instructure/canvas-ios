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

protocol DashboardViewProtocol: class {
    func updateNavBar(logoUrl: URL, color: UIColor, backgroundColor: UIColor)
    func updateDisplay(_ viewModel: DashboardViewModel)
}

class DashboardViewController: UIViewController, DashboardViewProtocol {
    @IBOutlet weak var collectionView: UICollectionView?
    var logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

    var presenter: DashboardPresenterProtocol?
    var viewModel: DashboardViewModel?

    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(DashboardViewController.refreshControlHandler(_:)), for: .valueChanged)
        return rc
    }()

    let gutterWidth: CGFloat = 16
    let shadowMargin: CGFloat = 5
    let coursesColumns: CGFloat = 2
    let groupsColumns: CGFloat = 1

    static func create(env: AppEnvironment = .shared) -> DashboardViewController {
        let storyboard = UIStoryboard(name: "DashboardViewController", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "vc") as? DashboardViewController else {
            fatalError("Must create DashboardViewController from a storyboard in \(#function)")
        }
        let presenter = DashboardPresenter(env: env, view: vc)
        vc.presenter = presenter
        return vc
    }

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar Setup
        let editBarButton = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: .plain, target: self, action: #selector(editBarButtonTapped(object:)))
        navigationItem.rightBarButtonItem = editBarButton

        navigationItem.titleView = logoView
        logoView.contentMode = .scaleAspectFit
        logoView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 44).isActive = true

        // Collection View Setup
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.refreshControl = refreshControl

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
    func refreshControlHandler(_ sender: Any) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        refreshView()
    }

    func refreshView() {
        presenter?.refreshRequested()
    }

    func updateNavBar(logoUrl: URL, color: UIColor, backgroundColor: UIColor) {
        navigationController?.navigationBar.barTintColor = backgroundColor
        navigationController?.navigationBar.tintColor = color.ensureContrast(against: backgroundColor)
        navigationController?.navigationBar.barStyle = backgroundColor.luminance < 0.5 ? .black : .default
        logoView.load(url: logoUrl)
    }

    func updateDisplay(_ viewModel: DashboardViewModel) {
        self.viewModel = viewModel

        // check for empty state

        // display courses
        collectionView?.reloadData()
        refreshControl.endRefreshing()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    @objc
    func editBarButtonTapped(object: Any) {
        // TODO:
        //delegate?.editButtonWasTapped()

        // REMOVE
        let alert = UIAlertController(title: "Edit Favorites", message: "Hook me up chief! See line \(#line) in \(#file)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func itemWasSelected(at indexPath: IndexPath) {
        guard let viewModel = viewModel,
            let section: DashboardViewSection = DashboardViewSection(rawValue: indexPath.section)
            else { return }

        switch section {
        case .courses:
            break
        case .groups:
            let route = Route.group(viewModel.groups[indexPath.item].groupID)
            router.route(to: route, from: self, options: nil)
        }
    }
}

extension DashboardViewController: ErrorViewController {
    func showError(_ error: Error) {
        print("Dashboard error: \(error.localizedDescription)")
    }
}

extension DashboardViewController: UICollectionViewDataSource {
    enum DashboardViewSection: Int {
        case courses = 0
        case groups = 1
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let vm = viewModel else {
            return 0
        }

        return (vm.favorites.count + vm.groups.count) > 0 ? 2 : 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else {
            return 0
        }

        if section == DashboardViewSection.courses.rawValue {
            return viewModel.favorites.count
        }

        return  viewModel.groups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else {
            return UICollectionViewCell(frame: CGRect.zero)
        }

        if indexPath.section == DashboardViewSection.courses.rawValue {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseCard", for: indexPath) as? DashboardCourseCell else {
                fatalError("dequeueReusableCell for courseCard must return DashboardCourseCell in \(#function)")
            }
            let model = viewModel.favorites[indexPath.row]
            cell.configure(with: model)

            cell.optionsCallback = { [unowned self, model] in
                // TODO:
                //self.delegate?.courseWasSelected(model.courseID)

                // REMOVE
                let alert = UIAlertController(title: "Course Options", message: "Course options was tapped for Id => \(model.courseID). See line \(#line) in \(#file)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groupCard", for: indexPath) as? DashboardGroupCell else {
            fatalError("dequeueReusableCell for courseCard must return DashboardCourseCell in \(#function)")
        }
        let group = viewModel.groups[indexPath.row]
        cell.configure(with: group)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let v = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                          withReuseIdentifier: "header",
                                                                          for: indexPath) as? DashboardSectionHeaderView else {
                fatalError("dequeueReusableSupplementaryView for header must return DashboardSectionHeaderView in \(#function)")
            }

            var title: String
            var rightText: String?
            var rightColor: UIColor?
            var action: (() -> Void)?
            if indexPath.section == DashboardViewSection.courses.rawValue {
                title = NSLocalizedString("Courses", comment: "")
                rightText = NSLocalizedString("See All", comment: "")
                rightColor = viewModel?.primaryButtonColor
                action = { [unowned self] in
                    self.presenter?.seeAllWasTapped()
                }
            } else {
                title = NSLocalizedString("Groups", comment: "")
            }

            v.configure(title: title, rightText: rightText, rightColor: rightColor, rightAction: action)
            v.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
            return v
        }

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        itemWasSelected(at: indexPath)
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch DashboardViewSection(rawValue: indexPath.section) ?? .courses {
        case .courses:
            return CGSize(width: (collectionView.bounds.width - ((coursesColumns+1) * gutterWidth)) / coursesColumns + shadowMargin * 2, height: 173)
        case .groups:
            return CGSize(width: (collectionView.bounds.width - ((groupsColumns+1) * gutterWidth)) / groupsColumns + shadowMargin * 2, height: 92)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let margin = gutterWidth - shadowMargin
        switch DashboardViewSection(rawValue: section) ?? .courses {
        case .courses:
            return UIEdgeInsets(top: -shadowMargin, left: margin, bottom: 0, right: margin)
        case .groups:
            return UIEdgeInsets(top: -shadowMargin, left: margin, bottom: gutterWidth, right: margin)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch DashboardViewSection(rawValue: section) ?? .courses {
        case .courses, .groups:
            return gutterWidth - (shadowMargin * 2)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch DashboardViewSection(rawValue: section) ?? .courses {
        case .courses, .groups:
            return gutterWidth - (shadowMargin * 2)
        }
    }
}
