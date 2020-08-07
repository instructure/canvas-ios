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
    public class Props: ObservableObject {
        @Published var filter: String = ""
        @Published var pendingFavorites: Set<String> = []
        @Published var loading = false
    }

    @Environment(\.appEnvironment) var env: AppEnvironment
    @Environment(\.viewController) var controller: () -> UIViewController?
    @ObservedObject var allCourses: Store<GetAllCourses>
    @ObservedObject var props = Props()

    static var configureAppearance: () -> Void = {
        // This will only run once
        let appearance = UITableViewHeaderFooterView.appearance(whenContainedInInstancesOf: [CoreHostingController<Self>.self])
        appearance.tintColor = UIColor.backgroundLightest
        appearance.hasBorderShadow = true
        return { }
    }()

    static var searchBarHeight: CGFloat = UISearchBar().sizeThatFits(.zero).height

    public static func create() -> CourseListView {
        let env = AppEnvironment.shared
        let props = Props()
        props.loading = true

        let allCourses = env.subscribe(GetAllCourses()) { store in
            if !store.pending {
                props.loading = false
            }
        }

        allCourses.exhaust()
        configureAppearance()
        return CourseListView(allCourses: allCourses, props: props)
    }

    public var body: some View {
        let view: AnyView
        if props.loading {
            view = AnyView(ActivityIndicatorView())
        } else if allCourses.isEmpty {
            view = AnyView(empty)
        } else {
            view = AnyView(courseList)
        }
        return view.navigationBarTitle("All Courses")
    }

    var empty: some View {
        EmptyViewRepresentable(
            title: NSLocalizedString("No Courses", bundle: .core, comment: ""),
            body: NSLocalizedString("It looks like there aren’t any courses associated with this account. Visit the web to create a course today.", bundle: .core, comment: ""),
            imageName: "PandaTeacher"
        )
    }

    var courseList: some View {
        let filter = props.filter.lowercased()
        let filteredCourses = allCourses.filter { course in
            props.filter.isEmpty ||
                course.name?.lowercased().contains(filter) == true ||
                course.courseCode?.lowercased().contains(filter) == true
        }
        let currentEnrollments = filteredCourses.filter { !$0.isPastEnrollment && !$0.isFutureEnrollment }
        let pastEnrollments = filteredCourses.filter { $0.isPastEnrollment }
        let futureEnrollments = filteredCourses.filter { $0.isFutureEnrollment }

        return GeometryReader { outerGeometry in
            List {
                Section {
                    ZStack {
                        CircleRefreshControl.AsView { control in
                            control.beginRefreshing()
                            self.allCourses.refresh(force: true) { _ in
                                control.endRefreshing()
                            }
                        }.frame(height: 0)
                        SearchBarView(text: self.$props.filter, placeholder: NSLocalizedString("Search", comment: ""))
                    }.listRowInsets(EdgeInsets())
                }
                self.enrollmentSection(Text("Current Enrollments", bundle: .core), courses: currentEnrollments)
                self.enrollmentSection(Text("Past Enrollments", bundle: .core), courses: pastEnrollments)
                self.enrollmentSection(Text("Future Enrollments", bundle: .core), courses: futureEnrollments)
                if filteredCourses.isEmpty {
                    Text("No matching courses", bundle: .core)
                        .frame(height: outerGeometry.frame(in: .local).height - Self.searchBarHeight)
                        .frame(maxWidth: .infinity)
                        .listRowInsets(EdgeInsets())
                }
            }
        }.avoidKeyboardArea()
        // Truncate everything to one line. Can't decide if I like it better with or without this.
        // TODO: decide
         .lineLimit(1)
    }

    func enrollmentSection<Header: View>(_ header: Header, courses: [Course]) -> some View {
        let formattedHeader = courses.isEmpty ? nil : header
            .font(Font(UIFont.scaledNamedFont(.medium12)))
            .foregroundColor(.textDark)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        let pending = SetBinding(set: $props.pendingFavorites)
        return Section(header: formattedHeader) {
            ForEach(courses, id: \.id) { course in
                Cell(course: course, pending: pending[course.id]) {
                    guard let controller = self.controller() else { return }
                    self.env.router.route(to: "/courses/\(course.id)", from: controller)
                }.listRowInsets(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
            }
        }
    }

    struct Cell: View {
        @Environment(\.appEnvironment) var env: AppEnvironment
        @ObservedObject var course: Course
        @Binding var pending: Bool
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
            }
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
                    Image.starSolid.foregroundColor(.textDark)
                } else if course.isFavorite {
                    Image.starSolid.foregroundColor(.textInfo).accessibility(addTraits: .isSelected)
                } else {
                    Image.starLine.foregroundColor(.textDark)
                }
            }.frame(maxHeight: .infinity, alignment: .top)
                .buttonStyle(PlainButtonStyle())
                .accessibility(label: Text("favorite", bundle: .core))
        }

        var enrollmentStrings: [String] {
            [course.termName, course.enrollments?.first?.formattedRole].compactMap { $0 }
        }

        var label: some View {
            VStack(alignment: .leading) {
                Text(course.name ?? "").font(Font(UIFont.scaledNamedFont(.semibold16)))
                HStack {
                    ForEach(enrollmentStrings.interleave(separator: "|"), id: \.self) {
                        Text($0)
                            .foregroundColor(.textDark)
                            .font(Font(UIFont.scaledNamedFont(.medium14)))
                    }
                }
            }
        }

        @ViewBuilder
        var publishedIcon: some View {
            if env.app == .teacher {
                if course.isPublished {
                    Image.completeSolid.foregroundColor(.textSuccess)
                } else {
                    Image.noSolid.foregroundColor(.textDark)
                }
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
        ])).environment(\.appEnvironment.app, .teacher)
    }
}
#endif
