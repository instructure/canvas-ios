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
    @ObservedObject var allCourses: Store<GetAllCourses>

    @State var filter: String

    static var searchBarHeight: CGFloat = UISearchBar().sizeThatFits(.zero).height

    public init(
        allCourses: Store<GetAllCourses> = AppEnvironment.shared.subscribe(GetAllCourses()),
        filter: String = ""
    ) {
        self.allCourses = allCourses
        self._filter = State(wrappedValue: filter)
    }

    public var body: some View {
        GeometryReader { geometry in ScrollView { VStack(spacing: 0) {
            CircleRefresh { endRefreshing in
                allCourses.exhaust(force: true) { _ in
                    if allCourses.hasNextPage == false {
                        endRefreshing()
                    }
                    return true
                }
            }
            let width = geometry.size.width
            let height = geometry.size.height
            switch allCourses.state {
            case .loading:
                ZStack { CircleProgress() }
                    .frame(minWidth: width, minHeight: height)
            case .data:
                if #available(iOS 14, *) {
                    ScrollViewReader { scrollView in
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            SearchBar(
                                text: $filter.animation(.default),
                                placeholder: NSLocalizedString("Search", comment: ""),
                                onCancel: { withAnimation { scrollView.scrollTo(0, anchor: .top) } }
                            )
                            Divider().id(0) // target to scroll passed search
                            list(height)
                        }
                            .onAppear { scrollView.scrollTo(0, anchor: .top) }
                    }
                } else {
                    VStack(spacing: 0) {
                        SearchBar(
                            text: $filter.animation(.default),
                            placeholder: NSLocalizedString("Search", comment: "")
                        )
                        list(height)
                    }
                }
            case .empty:
                EmptyPanda(.Teacher,
                    title: Text("No Courses", bundle: .core),
                    message: Text("It looks like there aren’t any courses associated with this account. Visit the web to create a course today.", bundle: .core)
                )
                    .frame(minWidth: width, minHeight: height)
            case .error:
                ZStack {
                    Text(allCourses.error?.localizedDescription ?? "")
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

            .onAppear { allCourses.exhaust() }
    }

    var sections: ([Course], [Course], [Course]) {
        let filter = self.filter.lowercased()
        var current: [Course] = []
        var past: [Course] = []
        var future: [Course] = []
        for course in allCourses {
            let matches = filter.isEmpty ||
                course.name?.lowercased().contains(filter) == true ||
                course.courseCode?.lowercased().contains(filter) == true
            guard !course.accessRestrictedByDate, matches else { continue }
            if course.isFutureEnrollment {
                future.append(course)
            } else if course.isPastEnrollment {
                past.append(course)
            } else {
                current.append(course)
            }
        }
        return (current, past, future)
    }

    @ViewBuilder
    func list(_ height: CGFloat) -> some View {
        let (current, past, future) = sections
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
                        Cell(course: course)
                    }
                }
                    .lineLimit(2)
            }
        }
    }

    struct Cell: View {
        @ObservedObject var course: Course

        @Environment(\.appEnvironment) var env
        @Environment(\.viewController) var controller

        @State var pending: Bool = false

        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                Button(action: toggleFavorite) {
                    let icon = pending ? Icon.starSolid.foregroundColor(.textDark) :
                        course.isFavorite ? Icon.starSolid.foregroundColor(.textInfo) :
                        Icon.starLine.foregroundColor(.textDark)
                    icon.padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 12))
                }
                    .buttonStyle(PlainButtonStyle())
                    .accessibility(label: Text("favorite", bundle: .core))
                    .accessibility(addTraits: course.isFavorite ? .isSelected : [])

                Button(action: {
                    env.router.route(to: "/courses/\(course.id)", from: controller)
                }, label: { HStack {
                    VStack(alignment: .leading) {
                        Text(course.name ?? "")
                            .font(.semibold16).foregroundColor(.textDarkest)
                        HStack(spacing: 8) {
                            let role = course.enrollments?.first?.formattedRole
                            course.termName.map { Text($0) }
                            if course.termName != nil && role != nil {
                                Text(verbatim: "|")
                            }
                            role.map { Text($0) }
                        }
                            .font(.medium14).foregroundColor(.textDark)
                    }
                        .padding(.vertical, 16)

                    Spacer()

                    if course.hasTeacherEnrollment {
                        let icon = course.isPublished ? Icon.completeSolid.foregroundColor(.textSuccess) :
                            Icon.noSolid.foregroundColor(.textDark)
                        icon.padding(16)
                    } else {
                        DisclosureIndicator().padding(16)
                    }
                } })
                    .accessibilityElement(children: .ignore)
                    .accessibility(label: accessibilityLabel)
            }
        }

        var accessibilityLabel: Text {
            Text([
                course.name,
                course.termName,
                course.enrollments?.first?.formattedRole,
                !course.hasTeacherEnrollment ? nil : course.isPublished ?
                    NSLocalizedString("published", comment: "") :
                    NSLocalizedString("unpublished", comment: ""),
            ].compactMap { $0 }.joined(separator: ", "))
        }

        func toggleFavorite() {
            guard !pending else { return }
            withAnimation { pending = true }
            MarkFavoriteCourse(courseID: course.id, markAsFavorite: !course.isFavorite).fetch { _, _, _ in
                withAnimation { pending = false }
            }
        }
    }
}

#if DEBUG
struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView(allCourses: PreviewStore(useCase: GetAllCourses(), contents: [
            APICourse.make(id: "1", term: .make(name: "Fall 2020"), is_favorite: true),
            APICourse.make(id: "2", workflow_state: .available),
            APICourse.make(
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
            ),
            APICourse.make(id: "4", start_at: .distantFuture, end_at: .distantFuture),
        ]))
    }
}
#endif
