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

import Combine
import SwiftUI

public struct AllCoursesView: View, ScreenViewTrackable {
    @ObservedObject private var viewModel: AllCoursesViewModel
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/courses")
    static var searchBarHeight: CGFloat = UISearchBar().sizeThatFits(.zero).height

    public init(viewModel: AllCoursesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            RefreshableScrollView {
                VStack(spacing: 0) {
                    let width = geometry.size.width
                    let height = geometry.size.height
                    switch viewModel.state {
                    case .loading:
                        ZStack {
                            ProgressView()
                                .progressViewStyle(.indeterminateCircle())
                        }
                        .frame(minWidth: width, minHeight: height)
                    case let .data(sections):
                        ScrollViewReader { scrollView in
                            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                                let binding = Binding {
                                    viewModel.filter.value
                                } set: { newValue, _ in
                                    viewModel.filter.send(newValue)
                                }

                                SearchBar(
                                    text: binding,
                                    placeholder: NSLocalizedString("Search", comment: ""),
                                    onCancel: { withAnimation { scrollView.scrollTo(0, anchor: .bottom) } }
                                )

                                if sections.isEmpty {
                                    EmptyPanda(
                                        .NoResults,
                                        title: Text("No Results", bundle: .core),
                                        message: Text("We couldn't find any courses like that.", bundle: .core)
                                    )
                                } else {
                                    courseAndGroupList(sections: sections).id(0)
                                }
                            }
                            .onAppear { scrollView.scrollTo(0, anchor: .top) }
                        }
                    case .empty:
                        EmptyPanda(
                            .Teacher,
                            title: Text("No Courses", bundle: .core),
                            message: Text(
                                "It looks like there aren’t any courses associated with this account. Visit the web to create a course today.",
                                bundle: .core
                            )
                        )
                        .frame(minWidth: width, minHeight: height)
                    case .error:
                        ZStack {
                            Text("Something went wrong", bundle: .core)
                                .font(.regular16).foregroundColor(.textDanger)
                                .multilineTextAlignment(.center)
                        }
                        .frame(minWidth: width, minHeight: height)
                    }
                }
            } refreshAction: { endRefreshing in
                viewModel.refresh(completion: endRefreshing)
            }
        }
        .avoidKeyboardArea()
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))

        .navigationBarStyle(.global)
        .navigationTitle(NSLocalizedString("All Courses", comment: ""), subtitle: nil)
    }

    @ViewBuilder
    func courseAndGroupList(sections: AllCoursesSections) -> some View {
        if !sections.courses.isEmpty {
            Spacer()
            Text("Courses", bundle: .core)
                .font(.heavy24).foregroundColor(.textDarkest)
                .accessibility(addTraits: .isHeader)
                .padding(.leading, 16)
            Spacer()
            Divider()
            Spacer()
            Text("Select courses for Dashboard or navigate to course details.", bundle: .core)
                .font(.regular16).foregroundColor(.textDarkest)
                .accessibility(addTraits: .isHeader)
                .padding(.leading, 16)
            Spacer()
            CourseListSection(
                header: Text("Current Enrollments", bundle: .core),
                courses: sections.courses.current
            )
            CourseListSection(
                header: Text("Past Enrollments", bundle: .core),
                courses: sections.courses.past
            )
            CourseListSection(
                header: Text("Future Enrollments", bundle: .core),
                courses: sections.courses.future
            )
        }

        if !sections.groups.isEmpty {
            Spacer()
            Divider()
            Spacer()
            Text("Groups", bundle: .core)
                .font(.heavy24).foregroundColor(.textDarkest)
                .accessibility(addTraits: .isHeader)
                .padding(.leading, 16)
            Spacer()
            Divider()
            Spacer()
            Text("Select groups for Dashboard or navigate to course details.", bundle: .core)
                .font(.regular16).foregroundColor(.textDarkest)
                .accessibility(addTraits: .isHeader)
                .padding(.leading, 16)
            Spacer()
            CourseListSection2(
                header: Text("Current groups"),
                groups: sections.groups
            )
            Divider()
        }
    }

    struct CourseListSection2: View {
        let header: Text
        let groups: [AllCoursesGroupItem]

        var body: some View {
            if !groups.isEmpty {
                ForEach(groups, id: \.id) { group in
                    if group.id != groups.first?.id { Divider() }
                    AllCoursesCellView(item: .group(group))
                }
            }
        }
    }

    struct CourseListSection: View {
        let header: Text
        let courses: [AllCoursesCourseItem]

        var body: some View {
            if !courses.isEmpty {
                Section(header: ListSectionHeader(isLarge: true) { header }) {
                    ForEach(courses, id: \.courseId) { course in
                        if course.courseId != courses.first?.courseId { Divider() }
                        AllCoursesCellView(item: .course(course))
                    }
                }
            }
        }
    }
}

#if DEBUG

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        AllCoursesAssembly.makePreview()
    }
}

#endif
