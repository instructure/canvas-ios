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

public struct CourseListView: View {
    @ObservedObject private var viewModel: CourseListViewModel

    static var searchBarHeight: CGFloat = UISearchBar().sizeThatFits(.zero).height

    public init(viewModel: CourseListViewModel = CourseListViewModel()) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in ScrollView { VStack(spacing: 0) {
            CircleRefresh { endRefreshing in
                viewModel.refresh(completion: endRefreshing)
            }
            let width = geometry.size.width
            let height = geometry.size.height
            switch viewModel.state {
            case .loading:
                ZStack { CircleProgress() }
                    .frame(minWidth: width, minHeight: height)
            case .data(let sections):
                ScrollViewReader { scrollView in
                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        SearchBar(
                            text: $viewModel.filter.animation(.default),
                            placeholder: NSLocalizedString("Search", comment: ""),
                            onCancel: { withAnimation { scrollView.scrollTo(0, anchor: .top) } }
                        )
                        Divider().id(0) // target to scroll passed search
                        list(height, sections: sections)
                    }
                        .onAppear { scrollView.scrollTo(0, anchor: .top) }
                }
            case .empty:
                EmptyPanda(.Teacher,
                    title: Text("No Courses", bundle: .core),
                    message: Text("It looks like there aren’t any courses associated with this account. Visit the web to create a course today.", bundle: .core)
                )
                    .frame(minWidth: width, minHeight: height)
            case .error(let message):
                ZStack {
                    Text(message)
                        .font(.regular16).foregroundColor(.textDanger)
                        .multilineTextAlignment(.center)
                }
                    .frame(minWidth: width, minHeight: height)
            }
        } } }
            .avoidKeyboardArea()
            .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))

            .navigationBarStyle(.global)
            .navigationTitle(NSLocalizedString("All Courses", comment: ""), subtitle: nil)

            .onAppear { viewModel.viewDidAppear() }
    }

    @ViewBuilder
    func list(_ height: CGFloat, sections: CourseListViewModel.Sections) -> some View {
        let current = sections.current
        let past = sections.past
        let future = sections.future

        if current.isEmpty, past.isEmpty, future.isEmpty {
            EmptyPanda(.NoResults,
                title: Text("No Results", bundle: .core),
                message: Text("We couldn't find any courses like that.", bundle: .core)
            )
                .frame(minHeight: height - Self.searchBarHeight)
        } else {
            CourseListSection(header: Text("Current Enrollments", bundle: .core), courses: current)
            CourseListSection(header: Text("Past Enrollments", bundle: .core), courses: past)
            CourseListSection(header: Text("Future Enrollments", bundle: .core), courses: future)
            Divider()
        }
    }

    struct CourseListSection: View {
        let header: Text
        let courses: [Course]

        var body: some View {
            if !courses.isEmpty {
                Section(header: ListSectionHeader { header }) {
                    ForEach(courses, id: \.id) { course in
                        if course.id != courses.first?.id { Divider() }
                        CourseListCell(course: course)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct CourseListView_Previews: PreviewProvider {
    private static let environment = PreviewEnvironment()

    static var previews: some View {
        let currentCourses = Course.save([
            .make(id: "1", term: .make(name: "Fall 2020"), is_favorite: true),
            .make(id: "2", workflow_state: .available),
        ], in: environment.globalDatabase.viewContext)
        let pastCourse = Course.save(.make(
                id: "3",
                workflow_state: .completed,
                start_at: .distantPast,
                end_at: .distantPast,
                enrollments: [ .make(
                    id: "6",
                    course_id: "3",
                    enrollment_state: .completed,
                    type: "TeacherEnrollment",
                    user_id: "1",
                    role: "TeacherEnrollment"
                ), ]
            ), in: environment.globalDatabase.viewContext)
        let futureCourse = Course.save(.make(id: "4", start_at: .distantFuture, end_at: .distantFuture), in: environment.globalDatabase.viewContext)
        let viewModel = CourseListViewModel(state: .data(.init(
            current: currentCourses,
            past: [pastCourse],
            future: [futureCourse]
        )))
        CourseListView(viewModel: viewModel)
    }
}
#endif
