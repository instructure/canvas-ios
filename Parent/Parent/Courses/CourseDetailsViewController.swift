//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class CourseDetailsViewController: HorizontalMenuViewController {
    private var gradesViewController: GradeListViewController!
    private var syllabusViewController: Core.SyllabusViewController!
    private var summaryViewController: Core.SyllabusSummaryViewController!
    var courseID: String = ""
    var studentID: String = ""
    var viewControllers: [UIViewController] = []
    var readyToLayoutTabs: Bool = false
    var didLayoutTabs: Bool = false
    let env = AppEnvironment.shared
    var colorScheme: ColorScheme?
    var replyButton: FloatingButton?
    var replyStarted: Bool = false

    enum MenuItem: Int {
        case grades, syllabus, summary
    }

    lazy var student = env.subscribe(GetSearchRecipients(context: .course(courseID), userID: studentID)) { [weak self] in
        self?.messagingReady()
    }

    lazy var teachers = env.subscribe(GetSearchRecipients(context: .course(courseID), qualifier: .teachers)) { [weak self] in
        self?.messagingReady()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseReady()
    }

    lazy var settings = env.subscribe(GetCourseSettings(courseID: courseID)) { [weak self] in
        self?.courseReady()
    }

    lazy var frontPages = env.subscribe(GetFrontPage(context: .course(courseID))) { [weak self] in
        self?.courseReady()
    }

    lazy var tabs = env.subscribe(GetContextTabs(context: .course(courseID))) { [weak self] in
        self?.courseReady()
    }

    static func create(courseID: String, studentID: String) -> CourseDetailsViewController {
        let controller = CourseDetailsViewController(nibName: nil, bundle: nil)
        controller.courseID = courseID
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundLightest
        colorScheme = ColorScheme.observee(studentID)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.useContextColor(colorScheme?.color)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)

        delegate = self
        courses.refresh(force: true)
        frontPages.refresh(force: true)
        tabs.refresh(force: true)
        student.refresh()
        teachers.refresh()
        settings.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readyToLayoutTabs = true
        courseReady()
    }

    override func setupPages() {
        super.setupPages()
        // This is to prevent the swipe to back gesture interfering with the collectionview horizontal scroll when on the first page
        pages?.bounces = false
    }

    func configureGrades() {
        gradesViewController = GradeListViewController.create(courseID: courseID, userID: studentID, colorDelegate: self)
        gradesViewController.gradeListCellIconDelegate = self
        viewControllers.append(gradesViewController)
    }

    func configureSyllabus() {
        syllabusViewController = Core.SyllabusViewController.create(courseID: courseID)
        viewControllers.append(syllabusViewController)
    }

    func configureSummary() {
        summaryViewController = Core.SyllabusSummaryViewController.create(courseID: courseID, colorDelegate: self)
        viewControllers.append(summaryViewController)
    }

    func configureFrontPage() {
        let vc = CoreWebViewController()
        vc.webView.loadHTMLString(frontPages.first?.body ?? "", baseURL: nil)
        viewControllers.append(vc)
    }

    func configureComposeMessageButton() {
        let buttonSize: CGFloat = 56
        let margin: CGFloat = 16
        let bottomMargin: CGFloat = 50

        replyButton = FloatingButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        replyButton?.configuration = UIButton.Configuration.plain()
        replyButton?.accessibilityLabel = NSLocalizedString("Compose Message", comment: "")
        replyButton?.accessibilityIdentifier = "Grades.composeMessageButton"
        replyButton?.accessibilityTraits.insert(.header)
        replyButton?.setImage(UIImage.commentSolid, for: .normal)
        replyButton?.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 17, leading: 17, bottom: 15, trailing: 15)
        replyButton?.tintColor = .white
        replyButton?.backgroundColor = colorScheme?.color.darkenToEnsureContrast(against: .white)
        if let replyButton = replyButton { view.addSubview(replyButton) }

        let metrics: [String: CGFloat] = ["buttonSize": buttonSize, "margin": margin, "bottomMargin": bottomMargin]
        replyButton?.addConstraintsWithVFL("H:[view(buttonSize)]-(margin)-|", metrics: metrics)
        replyButton?.addConstraintsWithVFL("V:[view(buttonSize)]-(bottomMargin)-|", metrics: metrics)
        replyButton?.addTarget(self, action: #selector(actionReplyButtonClicked(_:)), for: .primaryActionTriggered)
    }

    func courseReady() {
        title = courses.first?.name
        let pending = courses.pending || frontPages.pending || tabs.pending || settings.pending
        if !pending, readyToLayoutTabs, !didLayoutTabs, let course = courses.first {
            didLayoutTabs = true
            configureGrades()
            let showSummary = settings.first?.syllabusCourseSummary == true
            switch course.defaultView {
            case .wiki:
                if let page = frontPages.first, !page.body.isEmpty {
                    configureFrontPage()
                }
            case .syllabus where course.syllabusBody?.isEmpty == false:
                configureSyllabus()
                if showSummary { configureSummary() }
            default:
                let syllabusTab = tabs.first { $0.id == "syllabus" }
                if syllabusTab != nil, course.syllabusBody?.isEmpty == false {
                    configureSyllabus()
                    if showSummary { configureSummary() }
                }
            }

            layoutViewControllers()
            configureComposeMessageButton()
        }
    }

    func messagingReady() {
        let pending = teachers.pending || student.pending
        if !pending && replyStarted {
            let name = student.first?.fullName ?? ""
            var tabTitle = titleForSelectedTab() ?? ""
            tabTitle = tabTitle.replacingOccurrences(of: NSLocalizedString("Summary", comment: ""), with: NSLocalizedString("Syllabus", comment: ""))
            var template = NSLocalizedString("Regarding: %@, %@", comment: "Regarding <John Doe>, <Grades | Syllabus>")
            let subject = String.localizedStringWithFormat(template, name, tabTitle)
            template = NSLocalizedString("Regarding: %@, %@", comment: "Regarding <John Doe>, [link to grades or syllabus]")
            let compose = ComposeViewController.create(
                context: .course(courseID),
                observeeID: studentID,
                recipients: teachers.all,
                subject: subject,
                hiddenMessage: String.localizedStringWithFormat(template, name, associatedTabConversationLink())
            )
            env.router.show(compose, from: self, options: .modal(isDismissable: false, embedInNav: true), analyticsRoute: "/conversations/compose")
            replyButton?.isEnabled = true
        }
    }

    private func associatedTabConversationLink() -> String {
        let na = NSLocalizedString("n/a", comment: "")
        guard let menuItem = MenuItem(rawValue: selectedIndexPath.row) else { return na }
        guard let baseURL = env.currentSession?.baseURL, var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { return na }
        switch menuItem {
        case .grades:
            components.path = "/courses/\(courseID)/grades/\(studentID)"
            return components.url?.absoluteString ?? na
        case .syllabus, .summary:
            if let syllabusTab = tabs.first(where: { $0.id == "syllabus" }),
                courses.first?.syllabusBody?.isEmpty == false,
                let htmlURL = syllabusTab.htmlURL {
                components.path = htmlURL.path
                return components.url?.absoluteString ?? na
            }
            return na
        }
    }

    @IBAction func actionReplyButtonClicked(_ sender: UIButton) {
        sender.isEnabled = false
        replyStarted = true
        messagingReady()
    }
}

extension CourseDetailsViewController: ColorDelegate {
    var iconColor: UIColor? {
        return colorScheme?.color
    }
}

extension CourseDetailsViewController: HorizontalPagedMenuDelegate {
    func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .grades: identifier = "grades"
        case .syllabus: identifier = "syllabus"
        case .summary: identifier = "summary"
        }
        return "CourseDetail.\(identifier)MenuItem"
    }

    var menuItemSelectedColor: UIColor? {
        return colorScheme?.color
    }

    func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .grades:
            return NSLocalizedString("Grades", comment: "")
        case .syllabus:
            switch courses.first?.defaultView {
            case .wiki:
                return NSLocalizedString("Front Page", comment: "")
            case .syllabus:
                return NSLocalizedString("Syllabus", comment: "")
            default:
                return NSLocalizedString("Syllabus", comment: "")
            }
        case .summary:
            return NSLocalizedString("Summary", comment: "")
        }
    }
}

extension CourseDetailsViewController: GradeListCellIconDelegate {
    public func iconImage(for assignment: Assignment?) -> UIImage? {
        //  all quizzes in parent come back as `lockedForUser` so it's always
        //  showing the lock icon rather than the quiz icon
        if assignment?.quizID != nil {
            return .quizLine
        } else {
            return assignment?.icon
        }
    }
}
