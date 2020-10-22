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
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @ObservedObject var allCourses: Store<GetAllCourses>

    public class Props: ObservableObject {
        @Published public var filter: String

        public init(filter: String = "") {
            self.filter = filter
        }
    }
    @ObservedObject var props: Props
    let useList: Bool

    static var configureAppearance: () -> Void = {
        // This will only run once
        let appearance = UITableViewHeaderFooterView.appearance(whenContainedInInstancesOf: [CoreHostingController<Self>.self])
        appearance.tintColor = UIColor.backgroundLightest
        appearance.hasBorderSeparators = true
        return { }
    }()

    static var searchBarHeight: CGFloat = UISearchBar().sizeThatFits(.zero).height

    public init(allCourses: Store<GetAllCourses>? = nil, props: Props = Props(), useList: Bool = true) {
        self.allCourses = allCourses ?? AppEnvironment.shared.subscribe(GetAllCourses()).exhaust()
        self.useList = useList
        self.props = props
        Self.configureAppearance()
    }

    public var body: some View {
        ZStack {
            if allCourses.pending && allCourses.isEmpty {
                CircleProgress()
                    .testID("loading")
            } else if allCourses.isEmpty {
                EmptyPanda(.Teacher,
                    title: Text("No Courses", bundle: .core),
                    message: Text("It looks like there aren’t any courses associated with this account. Visit the web to create a course today.", bundle: .core)
                )
                    .testID("empty")
            } else {
                courseList
            }
        }
            .navigationBarTitle("All Courses")
    }

    @ViewBuilder
    func list<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if useList {
            List(content: content)
        } else {
            VStack(content: content)
        }
    }

    @ViewBuilder
    func section<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if useList {
            Section(content: content)
        } else {
            VStack(content: content)
        }
    }

    @ViewBuilder
    func section<Header: View, Content: View>(header: Header, @ViewBuilder content: () -> Content) -> some View {
        if useList {
            Section(header: header, content: content)
        } else {
            VStack {
                header
                content()
            }
        }
    }

    var courseList: some View {
        let filterString = props.filter.lowercased()
        let filteredCourses = allCourses.filter { course in
            guard !course.accessRestrictedByDate else { return false }
            return filterString.isEmpty ||
                course.name?.lowercased().contains(filterString) == true ||
                course.courseCode?.lowercased().contains(filterString) == true
        }
        let currentEnrollments = filteredCourses.filter { !$0.isPastEnrollment && !$0.isFutureEnrollment }
        let pastEnrollments = filteredCourses.filter { $0.isPastEnrollment }
        let futureEnrollments = filteredCourses.filter { $0.isFutureEnrollment }

        return GeometryReader { outerGeometry in
            self.list {
                self.section {
                    ZStack {
                        CircleRefreshControl.AsView { control in
                            control.beginRefreshing()
                            self.allCourses.refresh(force: true) { _ in
                                control.endRefreshing()
                            }
                        }.frame(height: 0)
                        SearchBarView(text: self.$props.filter, placeholder: NSLocalizedString("Search", comment: ""))
                            .testID(info: ["filter": self.props.filter])
                    }.listRowInsets(EdgeInsets())
                }
                self.enrollmentSection(Text("Current Enrollments", bundle: .core), courses: currentEnrollments, testID: "current")
                self.enrollmentSection(Text("Past Enrollments", bundle: .core), courses: pastEnrollments, testID: "past")
                self.enrollmentSection(Text("Future Enrollments", bundle: .core), courses: futureEnrollments, testID: "future")
                self.notFound(
                    shown: filteredCourses.isEmpty,
                    height: outerGeometry.frame(in: .local).height - Self.searchBarHeight
                )
            }.animation(.default, value: self.props.filter)
                .animation(.default, value: self.allCourses)
        }.avoidKeyboardArea()
            .lineLimit(2)
    }

    func formatHeader<Header: View>(_ header: Header) -> some View {
        header
            .font(.medium12)
            .foregroundColor(.textDark)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }

    @ViewBuilder
    func enrollmentSection<Header: View>(_ header: Header, courses: [Course], testID: String) -> some View {
        if !courses.isEmpty {
            section(header: formatHeader(header)) {
                ForEach(courses, id: \.id) { course in
                    Cell(course: course) {
                        env.router.route(to: "/courses/\(course.id)", from: controller)
                    }.listRowInsets(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
                }
            }.testID(.section, id: testID)
        }
    }

    func notFound(shown: Bool, height: CGFloat) -> some View {
        // All this for pretty animations
        let footer = Text("No matching courses", bundle: .core)
            .frame(height: shown ? height : 0)
            .animation(shown ? nil : .default, value: props.filter)
            .opacity(shown ? 1 : 0)
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets())
            .testID("no-match", info: ["shown": shown])
        return Section(footer: footer) { SwiftUI.EmptyView() }
    }

    struct Cell: View {
        @Environment(\.appEnvironment) var env
        @ObservedObject var course: Course
        @State private var pending: Bool = false
        let didSelect: () -> Void

        var body: some View {
            HStack {
                favoriteButton
                Button(action: didSelect) {
                    HStack {
                        label
                        Spacer()
                        publishedIcon
                    }
                }.accessibilityElement(children: .ignore)
                    .accessibility(label: accessibilityLabel)
                    .accessibility(addTraits: .isButton)
            }.testID(.cell, id: course.id)
        }

        var accessibilityLabel: Text {
            var texts = [
                course.name,
                course.termName,
                course.enrollments?.first?.formattedRole,
            ]
            if env.app == .teacher {
                texts.append(course.isPublished ?
                    NSLocalizedString("published", bundle: .core, comment: "") :
                    NSLocalizedString("unpublished", bundle: .core, comment: ""))
            }
            return Text(texts.compactMap { $0 }.joined(separator: ", "))
        }

        var favoriteButton: some View {
            Button(action: toggleFavorite) {
                if pending {
                    Icon.starSolid.foregroundColor(.textDark).testID("pending")
                } else if course.isFavorite {
                    Icon.starSolid.foregroundColor(.textInfo).testID("favorite")
                } else {
                    Icon.starLine.foregroundColor(.textDark).testID("not favorite")
                }
            }.frame(maxHeight: .infinity, alignment: .top)
                .buttonStyle(PlainButtonStyle())
                .animation(.default, value: pending)
                .accessibility(label: Text("favorite", bundle: .core))
                .accessibility(addTraits: course.isFavorite ? .isSelected : [])
        }

        var label: some View {
            let termName = course.termName
            let role = course.enrollments?.first?.formattedRole
            return VStack(alignment: .leading) {
                Text(course.name ?? "").testID("courseName").font(.semibold16)
                HStack {
                    if termName != nil {
                        Text(termName!).testID("term")
                    }
                    if termName != nil && role != nil {
                        Text(verbatim: "|")
                    }
                    if role != nil {
                        Text(role!).testID("role")
                    }
                }.foregroundColor(.textDark)
                    .font(.medium14)
            }
        }

        @ViewBuilder
        var publishedIcon: some View {
            if env.app == .teacher {
                if course.isPublished {
                    Icon.completeSolid.foregroundColor(.textSuccess).testID("published")
                } else {
                    Icon.noSolid.foregroundColor(.textDark).testID("unpublished")
                }
            }
        }

        func toggleFavorite() {
            guard !pending else { return }
            withAnimation {
                pending = true
            }
            MarkFavoriteCourse(courseID: course.id, markAsFavorite: !course.isFavorite).fetch { _, _, _ in
                withAnimation {
                    self.pending = false
                }
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
            APICourse.make(id: "3", workflow_state: .completed, start_at: .distantPast, end_at: .distantPast),
            APICourse.make(id: "4", start_at: .distantFuture, end_at: .distantFuture),
        ])).environment(\.appEnvironment.app, .teacher)
    }
}
#endif
