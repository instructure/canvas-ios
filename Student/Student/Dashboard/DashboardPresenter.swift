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

struct DashboardViewModel {
    struct Course {
        let courseID: String
        let title: String
        let abbreviation: String
        let color: UIColor
        let imageUrl: URL?
    }

    struct Group {
        let groupID: String
        let groupName: String
        let courseName: String?
        let term: String?
        let color: UIColor?
    }

    var navBackgroundColor: UIColor
    var navLogoUrl: URL
    var favorites: [Course]
    var groups: [Group]
}

protocol DashboardPresenterProtocol {
    func viewIsReady()
    func pageViewStarted()
    func pageViewEnded()
    func loadData()
    func refreshRequested()
    func courseWasSelected(_ courseID: String)
    func courseOptionsWasSelected(_ courseID: String)
    func groupWasSelected(_ groupID: String)
    func editButtonWasTapped()
    func seeAllWasTapped()
}

class DashboardPresenter: DashboardPresenterProtocol {
    weak var view: DashboardViewProtocol?

    init(view: DashboardViewProtocol?) {
        self.view = view
    }

    func courseWasSelected(_ courseID: String) {
        // route to details screen
    }

    func editButtonWasTapped() {
        // route to edit screen
    }

    func viewIsReady() {
        loadData()
    }

    func pageViewStarted() {
        // log page view
    }

    func pageViewEnded() {
        // log page view
    }

    func courseOptionsWasSelected(_ courseID: String) {
        // route/modal
    }

    func groupWasSelected(_ groupID: String) {
        // route
    }

    func seeAllWasTapped() {
        // route
        if let vc = view as? UIViewController {
            router.route(to: "/allcourses", from: vc)
        }
    }

    func refreshRequested() {
        loadData()
    }

    func loadData() {
        let vm = mockViewModel()
        view?.updateDisplay(vm)
    }

    func mockViewModel() -> DashboardViewModel {
        var courses = [DashboardViewModel.Course]()
        courses.append(DashboardViewModel.Course(courseID: "1", title: "A Navigation Test", abbreviation: "ANT", color: .darkGray,
            imageUrl: URL(string: "https://upload.wikimedia.org/wikipedia/commons/a/a0/Sunflower_as_gif_websafe.gif")))
        courses.append(DashboardViewModel.Course(courseID: "2", title: "Annotations", abbreviation: "ANN", color: .blue,
            imageUrl: URL(string: "https://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg")))
        courses.append(DashboardViewModel.Course(courseID: "3", title: "Announcements", abbreviation: "AN", color: .orange,
            imageUrl: URL(string: "https://media.giphy.com/media/CyNwabts0egVy/giphy.gif")))
        courses.append(DashboardViewModel.Course(courseID: "4", title: "Assignment Grades", abbreviation: "AG", color: .red,
            imageUrl: URL(string: "https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png")))
        //        courses.append(DashboardCourseModel(courseID: "5", title: "Quiz Questions", abbreviation: "QQ", color: .green, imageUrl: nil))
        //        courses.append(DashboardCourseModel(courseID: "6", title: "Quizzes NEXT", abbreviation: "QN", color: .cyan, imageUrl: nil))

        var groups = [DashboardViewModel.Group]()
        groups.append(DashboardViewModel.Group(groupID: "1", groupName: "Team 1", courseName: "Course Groups", term: "DEFAULT TERM", color: .blue))
        groups.append(DashboardViewModel.Group(groupID: "2", groupName: "Team 1", courseName: "Assignment Grades", term: "DEFAULT TERM", color: .red))
        groups.append(DashboardViewModel.Group(groupID: "3", groupName: "Mighty Pulp Wannabees", courseName: "Course Groups", term: "DEFAULT TERM", color: .green))
        groups.append(DashboardViewModel.Group(groupID: "4", groupName: "Bitter Water Assassins", courseName: "Course Groups", term: "DEFAULT TERM", color: .orange))

        let navBackgroundColor: UIColor = .black
        let logo = URL(string: "https://emoji.slack-edge.com/T028ZAGUD/laugh/2d2ad81e3d71f12e.gif")!

        return DashboardViewModel(navBackgroundColor: navBackgroundColor, navLogoUrl: logo, favorites: courses, groups: groups)
    }
}
