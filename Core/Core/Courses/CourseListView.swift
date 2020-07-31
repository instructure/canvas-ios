//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI
import Combine

// swiftlint:disable superfluous_disable_command multiple_closures_with_trailing_closure

@available(iOSApplicationExtension 13.0.0, *)
public struct CourseListView: View {
    @Environment(\.appEnvironment) var env: AppEnvironment
    @Environment(\.viewController) var controller: () -> UIViewController?
    @ObservedObject var allCourses: Store<GetAllCourses>
    @State var filter: String = ""

    static var configureAppearance: () -> Void = {
        // This will only run once
        UITableView.appearance(whenContainedInInstancesOf: [HostingController<Self>.self]).backgroundColor = .white
        return { }
    }()

    public static func create() -> CourseListView {
        let env = AppEnvironment.shared
        let allCourses = env.subscribe(GetAllCourses()) {}
        allCourses.exhaust()
        configureAppearance()
        return CourseListView(allCourses: allCourses)
    }

    @ViewBuilder
    public var body: some View {
        if allCourses.isEmpty {
            empty.navigationBarTitle("All Courses")
        } else {
            courseList.navigationBarTitle("All Courses")
        }
    }

    var empty: some View {
        EmptyViewRepresentable(
            title: NSLocalizedString("No Courses", comment: ""),
            body: NSLocalizedString("It looks like there aren’t any courses associated with this account. Visit the web to create a course today.", comment: ""),
            imageName: "PandaTeacher"
        )
    }

    var courseList: some View {
        // TODO: better searching
        let filteredCourses = allCourses.filter { filter.isEmpty || $0.name?.lowercased().contains(filter.lowercased()) == true }
        let currentEnrollments = filteredCourses.filter { !$0.isPastEnrollment && !$0.isFutureEnrollment }
        let pastEnrollments = filteredCourses.filter { $0.isPastEnrollment }
        let futureEnrollments = filteredCourses.filter { $0.isFutureEnrollment }
        return VStack(spacing: 0) {
            SearchBarView(text: $filter)
            if filteredCourses.isEmpty {
                Text("No matching courses").frame(maxHeight: .infinity)
            } else {
                Form {
                    enrollmentSection(Text("Current Enrollments"), courses: currentEnrollments)
                    enrollmentSection(Text("Past Enrollments"), courses: pastEnrollments)
                    enrollmentSection(Text("Future Enrollments"), courses: futureEnrollments)
                }
            }
        }
    }

    @ViewBuilder
    func enrollmentSection<Header: View>(_ header: Header, courses: [Course]) -> some View {
        if !courses.isEmpty {
            Section(header: header) {
                ForEach(courses, id: \.self) { course in
                    Cell(course: course) {
                        guard let controller = self.controller() else { return }
                        self.env.router.route(to: "/courses/\(course.id)", from: controller)
                    }
                    .listRowInsets(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
                }
            }
        }
    }

    struct Cell: View {
        @Environment(\.isTeacher) var isTeacher: Bool
        @ObservedObject var course: Course
        @State var pending = false
        let didSelect: () -> Void

        var body: some View {
            ZStack {
                Button(action: didSelect) { SwiftUI.EmptyView() }
                HStack {
                    favoriteButton
                    label
                    Spacer()
                    publishedIcon
                }
            }
        }

        var favoriteButton: some View {
            Button(action: toggleFavorite) {
                if pending {
                    Image.icon(.star, .solid).foregroundColor(.named(.ash))
                } else if course.isFavorite {
                    Image.icon(.star, .solid).foregroundColor(.named(.electric))
                } else {
                    Image.icon(.star, .line).foregroundColor(.named(.ash))
                }
            }.frame(maxHeight: .infinity, alignment: .top)
            .buttonStyle(PlainButtonStyle())
        }

        var label: some View {
            let enrollment = course.enrollments?.first
            let term = course.termName
            return VStack(alignment: .leading) {
                Text(course.name ?? "").fontWeight(.semibold)
                if enrollment != nil {
                    HStack {
                        if term != nil {
                            Text(term!)
                            Text(verbatim: "|")
                        }
                        Text(enrollment!.formattedRole ?? "")
                    }.foregroundColor(.named(.ash))
                }
            }
        }

        @ViewBuilder
        var publishedIcon: some View {
            if isTeacher && course.isPublished {
                Image.icon(.complete, .solid).foregroundColor(.named(.shamrock))
            } else if isTeacher {
                Image.icon(.no, .solid).foregroundColor(.named(.ash))
            }
        }

        func toggleFavorite() {
            guard !pending else { return }
            pending = true
            MarkFavoriteCourse(courseID: course.id, markAsFavorite: !course.isFavorite).fetch { _, _, _ in
                self.pending = false
            }
        }
    }
}

#if DEBUG
@available(iOSApplicationExtension 13.0.0, *)
struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView(allCourses: PreviewStore(useCase: GetAllCourses(), contents: [
            APICourse.make(id: "1", term: .make(name: "Fall 2020"), is_favorite: true),
            APICourse.make(id: "2", workflow_state: .available),
            APICourse.make(id: "3", workflow_state: .completed, start_at: .distantPast, end_at: .distantPast),
            APICourse.make(id: "4", start_at: .distantFuture, end_at: .distantFuture),
        ])).environment(\.isTeacher, true)
    }
}
#endif
