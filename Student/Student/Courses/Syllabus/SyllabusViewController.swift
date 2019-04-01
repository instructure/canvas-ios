//
// Copyright (C) 2019-present Instructure, Inc.
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

class SyllabusViewController: UIViewController {

    @IBOutlet weak var menu: HorizontalMenuView!
    @IBOutlet weak var scrollView: UIScrollView!
    var presenter: SyllabusPresenter!
    var titleView: TitleSubtitleView!
    var courseID: String = ""
    var color: UIColor?
    var syllabus: CoreWebView?
    var assignments: AssignmentListViewController?

    enum MenuItem: Int {
        case syllabus, assignments
    }

    static func create(courseID: String) -> SyllabusViewController {
        let vc = loadFromStoryboard()
        vc.courseID = courseID
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = SyllabusPresenter(courseID: courseID, view: self)
        view.backgroundColor = UIColor.white.ensureContrast(against: .named(.white))

        configureTitleView()
        configureSyllabus()
        configureAssignments()
        menu.delegate = self
        menu.reload()

        scrollView.delegate = self
        presenter.viewIsReady()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.contentSize = CGSize(width: view.bounds.size.width * 2, height: scrollView.bounds.size.height)
    }

    // MARK: - Setup

    func configureTitleView() {
        titleView = TitleSubtitleView.create()
        navigationItem.titleView = titleView
        titleView.title = NSLocalizedString("Course Syllabus", comment: "")
    }

    func configureSyllabus() {
        syllabus = CoreWebView(frame: CGRect.zero)
        guard let syllabus = syllabus else { return }
        scrollView.addSubview(syllabus)
        syllabus.addConstraintsWithVFL("H:|[view(==superview)]")
        syllabus.addConstraintsWithVFL("V:|[view(==superview)]|")
    }

    func configureAssignments() {
        assignments = AssignmentListViewController(courseID: courseID)
        guard let assignments = assignments else { return }
        embed(assignments, in: scrollView) { [weak self] (child, _) in
            guard let syllabus = self?.syllabus else { return }
            child.view.addConstraintsWithVFL("H:[syllabus][view(==superview)]|", views: ["syllabus": syllabus])
            child.view.pinToTopAndBottomOfSuperview()
        }
    }

    // MARK: -

    func showSyllabus() {
        guard let syllabus = syllabus else { return }
        scrollView.scrollRectToVisible(syllabus.frame, animated: true)
    }

    func showAssignments() {
        guard let assignments = assignments else { return }
        scrollView.scrollRectToVisible(assignments.view.frame, animated: true)
    }
}

extension SyllabusViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let assignmentsView = assignments?.view else { return }
        if assignmentsView.frame.contains(scrollView.contentOffset) {
            menu.selectMenuItem(at: IndexPath(row: MenuItem.assignments.rawValue, section: 0), animated: true)
        } else {
            menu.selectMenuItem(at: IndexPath(row: MenuItem.syllabus.rawValue, section: 0), animated: true)
        }
    }
}

extension SyllabusViewController: SyllabuseViewProtocol {
    func updateNavBar(courseCode: String?, backgroundColor: UIColor?) {
        titleView.subtitle = courseCode
        navigationController?.navigationBar.useContextColor(backgroundColor)
        color = backgroundColor?.ensureContrast(against: .named(.white))
    }

    func loadHtml(_ html: String?) {
        guard let html = html else { return }
        syllabus?.loadHTMLString(html, baseURL: nil)
    }
}

extension SyllabusViewController: HorizontalMenuDelegate {

    var selectedColor: UIColor? {
        return color
    }

    var maxItemWidth: CGFloat {
        return 200
    }

    var measurementFont: UIFont {
        return .scaledNamedFont(.rowTitle)
    }

    func menuItemCount() -> Int {
        return 2
    }

    func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .syllabus:
            return NSLocalizedString("Syllabus", comment: "")
        case .assignments:
            return NSLocalizedString("Assignments", comment: "")
        }
    }

    func didSelectItem(at: IndexPath) {
        guard let item = MenuItem(rawValue: at.row) else { return }
        switch item {
        case .syllabus:
            showSyllabus()
        case .assignments:
            showAssignments()
        }
    }
}
