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

struct AllCoursesViewModel {
    struct Course {
        let courseID: String
        let title: String
        let abbreviation: String
        let color: UIColor
        let imageUrl: String?
    }
    
    var current: [Course]
    var past: [Course]
}

protocol AllCoursesPresenterProtocol {
    func viewIsReady()
    func pageViewStarted()
    func pageViewEnded()
    func loadData()
    func courseWasSelected(_ courseID: String)
    func courseOptionsWasSelected(_ courseID: String)
}

class AllCoursesPresenter: AllCoursesPresenterProtocol {
    weak var view: AllCoursesViewProtocol?
    
    init(view: AllCoursesViewProtocol?) {
        self.view = view
    }
    
    func loadData() {
        let vm = mockViewModel()
        view?.updateDisplay(vm)

        // GetCourses(api: <#T##API#>, database: <#T##DatabaseStore#>, force: <#T##Bool#>)
        
    }
    
    func courseWasSelected(_ courseID: String) {
        // route to details screen
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
    
    func mockViewModel() -> AllCoursesViewModel {
        var courses = [AllCoursesViewModel.Course]()
        courses.append(AllCoursesViewModel.Course(courseID: "1", title: "A Navigation Test", abbreviation: "ANT", color: .darkGray, imageUrl: nil))
        courses.append(AllCoursesViewModel.Course(courseID: "2", title: "Annotations", abbreviation: "ANN", color: .blue, imageUrl: nil))
        courses.append(AllCoursesViewModel.Course(courseID: "3", title: "Announcements", abbreviation: "AN", color: .orange, imageUrl: nil))
        courses.append(AllCoursesViewModel.Course(courseID: "4", title: "Assignment Grades", abbreviation: "AG", color: .red, imageUrl: nil))
        courses.append(AllCoursesViewModel.Course(courseID: "5", title: "Quiz Questions", abbreviation: "QQ", color: .green, imageUrl: nil))
        courses.append(AllCoursesViewModel.Course(courseID: "6", title: "Quizzes NEXT", abbreviation: "QN", color: .cyan, imageUrl: nil))

        return AllCoursesViewModel(current: courses, past: courses)
    }
}
