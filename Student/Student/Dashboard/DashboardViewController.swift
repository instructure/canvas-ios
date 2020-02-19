//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit
import Core

protocol DashboardViewProtocol: ErrorViewController {
    func updateDisplay()
}

class DashboardViewController: UIViewController, DashboardViewProtocol {
    @IBOutlet weak var collectionView: UICollectionView?
    var logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

    var presenter: DashboardPresenter!

    lazy var refreshControl: CircleRefreshControl = {
        let rc = CircleRefreshControl()
        rc.addTarget(self, action: #selector(DashboardViewController.refreshControlHandler(_:)), for: .valueChanged)
        return rc
    }()

    let gutterWidth: CGFloat = 16
    let shadowMargin: CGFloat = 5
    let coursesColumns: CGFloat = 2
    let groupsColumns: CGFloat = 1

    static func create(env: AppEnvironment = .shared) -> DashboardViewController {
        let view = loadFromStoryboard()
        view.presenter = DashboardPresenter(env: env, view: view)
        return view
    }

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation Bar Setup
        let editBarButton = UIBarButtonItem(title: NSLocalizedString("Edit", bundle: .student, comment: ""), style: .plain, target: self, action: #selector(editBarButtonTapped(object:)))
        navigationItem.rightBarButtonItem = editBarButton

        navigationItem.titleView = logoView
        logoView.contentMode = .scaleAspectFit
        logoView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoView.load(url: Brand.shared.headerImageUrl)
        logoView.backgroundColor = Brand.shared.headerImageBackground

        // Collection View Setup
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.refreshControl = refreshControl
        collectionView?.registerCell(CourseCardCell.self)

        // Debug logs
        #if DEBUG
        let logs = UIBarButtonItem(title: "Logs", style: .plain, target: self, action: #selector(showLogs))
        addNavigationButton(logs, side: .left)
        let login = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(changeUser))
        addNavigationButton(login, side: .left)
        #endif

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
    func refreshControlHandler(_ sender: Any) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        refreshView()
    }

    func refreshView() {
        presenter?.refreshRequested()
    }

    func updateDisplay() {
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
        guard let section: DashboardViewSection = DashboardViewSection(rawValue: indexPath.section) else { return }

        switch section {
        case .courses:
            guard let id = presenter.courses[indexPath.item]?.id else { return }
            let route = Route.course(id)
            router.route(to: route, from: self)
        case .groups:
            guard let id = presenter.groups[indexPath.item]?.id else { return }
            let route = Route.group(id)
            router.route(to: route, from: self)
        }
    }

    @objc
    func showLogs() {
        router.route(to: Route.logs, from: self, options: .modal(embedInNav: true))
    }

    @objc
    func changeUser() {
        (UIApplication.shared.delegate as? LoginDelegate)?.changeUser()
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
        let groups = presenter?.groups.count ?? 0
        let courses = presenter?.courses.count ?? 0

        return (courses + groups) > 0 ? 2 : 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == DashboardViewSection.courses.rawValue {
            return presenter?.courses.count ?? 0
        }

        return  presenter?.groups.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == DashboardViewSection.courses.rawValue {
            let cell: CourseCardCell = collectionView.dequeue(for: indexPath)
            guard let model = presenter?.courses[indexPath.row] else { return UICollectionViewCell(frame: CGRect.zero) }
            let hideDashcardColorOverlays = presenter?.settings.first?.hideDashcardColorOverlays ?? false
            cell.configure(with: model, hideDashcardColorOverlays: hideDashcardColorOverlays)
            cell.optionsCallback = { [weak self, model] in
                // TODO:
                //self.delegate?.courseWasSelected(model.courseID)

                // REMOVE
                let alert = UIAlertController(title: "Course Options", message: "Course options was tapped for Id => \(model.id). See line \(#line) in \(#file)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }

            return cell
        }

        let cell: DashboardGroupCell = collectionView.dequeue(for: indexPath)
        if let group = presenter?.groups[indexPath.row] {
            cell.configure(with: group)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let v = collectionView.dequeue(DashboardSectionHeaderView.self, ofKind: kind, for: indexPath)
            var title: String
            var rightText: String?
            var action: (() -> Void)?
            if indexPath.section == DashboardViewSection.courses.rawValue {
                title = NSLocalizedString("Courses", bundle: .student, comment: "")
                rightText = NSLocalizedString("See All", bundle: .student, comment: "")
                action = { [unowned self] in
                    self.presenter?.seeAllWasTapped()
                }
            } else {
                title = NSLocalizedString("Groups", bundle: .student, comment: "")
            }

            v.configure(title: title, rightText: rightText, rightAction: action)
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
