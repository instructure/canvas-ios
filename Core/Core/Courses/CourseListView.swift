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
    @State private var filter = ""

    static var configureAppearance: () -> Void = {
        // This will only run once
        let appearance = UITableViewHeaderFooterView.appearance(whenContainedInInstancesOf: [CoreHostingController<Self>.self])
        appearance.tintColor = UIColor.backgroundLightest
        appearance.hasBorderSeparators = true
        return { }
    }()

    static var searchBarHeight: CGFloat = UISearchBar().sizeThatFits(.zero).height

    public init(allCourses: Store<GetAllCourses>? = nil) {
        self.allCourses = allCourses ?? AppEnvironment.shared.subscribe(GetAllCourses()).exhaust()
        Self.configureAppearance()
    }

    public var body: some View {
        let view: AnyView
        if allCourses.pending && allCourses.isEmpty {
            view = AnyView(CircleProgressView.AsView.create())
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
        let filterString = filter.lowercased()
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
            List {
                Section {
                    ZStack {
                        CircleRefreshControl.AsView { control in
                            control.beginRefreshing()
                            self.allCourses.refresh(force: true) { _ in
                                control.endRefreshing()
                            }
                        }.frame(height: 0)
                        SearchBarView(text: self.$filter, placeholder: NSLocalizedString("Search", comment: ""))
                    }.listRowInsets(EdgeInsets())
                }
                self.enrollmentSection(Text("Current Enrollments", bundle: .core), courses: currentEnrollments)
                self.enrollmentSection(Text("Past Enrollments", bundle: .core), courses: pastEnrollments)
                self.enrollmentSection(Text("Future Enrollments", bundle: .core), courses: futureEnrollments)
                self.notFound(
                    shown: filteredCourses.isEmpty,
                    height: outerGeometry.frame(in: .local).height - Self.searchBarHeight
                )
            }.animation(.default, value: self.filter)
                .animation(.default, value: self.allCourses)
        }.avoidKeyboardArea()
            .lineLimit(2)
    }

    func enrollmentSection<Header: View>(_ header: Header, courses: [Course]) -> some View {
        let formattedHeader = courses.isEmpty ? nil : header
            .font(.medium12)
            .foregroundColor(.textDark)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        return Section(header: formattedHeader) {
            ForEach(courses, id: \.id) { course in
                Cell(course: course) {
                    guard let controller = self.controller() else { return }
                    self.env.router.route(to: "/courses/\(course.id)", from: controller)
                }.listRowInsets(EdgeInsets(top: 16, leading: 18, bottom: 16, trailing: 18))
            }
        }
    }

    func notFound(shown: Bool, height: CGFloat) -> some View {
        // All this for pretty animations
        let footer = Text("No matching courses", bundle: .core)
            .frame(height: shown ? height : 0)
            .animation(shown ? nil : .default, value: filter)
            .opacity(shown ? 1 : 0)
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets())
        return Section(footer: footer) { SwiftUI.EmptyView() }
    }

    struct Cell: View {
        @Environment(\.appEnvironment) var env: AppEnvironment
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
                    Image.starSolid.foregroundColor(.textInfo)
                } else {
                    Image.starLine.foregroundColor(.textDark)
                }
            }.frame(maxHeight: .infinity, alignment: .top)
                .buttonStyle(PlainButtonStyle())
                .animation(.default, value: pending)
                .accessibility(label: Text("favorite", bundle: .core))
                .accessibility(addTraits: course.isFavorite ? .isSelected : [])
        }

        var enrollmentStrings: [String] {
            [course.termName, course.enrollments?.first?.formattedRole].compactMap { $0 }
        }

        var label: some View {
            VStack(alignment: .leading) {
                Text(course.name ?? "").font(.semibold16)
                HStack {
                    ForEach(enrollmentStrings.interleave(separator: "|"), id: \.self) {
                        Text($0)
                            .foregroundColor(.textDark)
                            .font(.medium14)
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
