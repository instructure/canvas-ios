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
                        loadingView(minWidth: width, minHeight: height)
                    case let .data(sections):
                        sectionsView(sections: sections)
                    case .empty:
                        emptyView(width: width, height: height)
                    case .error:
                        errorView(width: width, height: height)
                    }
                }
            } refreshAction: { endRefreshing in
                viewModel.refresh(completion: endRefreshing)
            }
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        .navigationBarStyle(.global)
        .navigationTitle(String(localized: "All Courses", bundle: .core), subtitle: nil)
    }

    @ViewBuilder
    func loadingView(minWidth: CGFloat, minHeight: CGFloat) -> some View {
        ZStack {
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        }
        .frame(minWidth: minWidth, minHeight: minHeight)
    }

    @ViewBuilder
    func sectionsView(sections: AllCoursesSections) -> some View {
        ScrollViewReader { scrollView in
            LazyVStack(alignment: sections.isEmpty ? .center : .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                let binding = Binding {
                    viewModel.filter.value
                } set: { newValue, _ in
                    viewModel.filter.send(newValue)
                }

                SearchBar(
                    text: binding,
                    placeholder: String(localized: "Search", bundle: .core),
                    onCancel: { withAnimation { scrollView.scrollTo(0, anchor: .top) } }
                )

                if sections.isEmpty {
                    Spacer()
                    EmptyPanda(
                        .NoResults,
                        title: Text("No Results", bundle: .core),
                        message: Text("We couldn't find any courses like that.", bundle: .core)
                    )
                    Spacer()
                } else {
                    courseAndGroupList(sections: sections).id(0)
                }
            }
            .frame(maxWidth: .infinity)
            .onFirstAppear { scrollView.scrollTo(0, anchor: .top) }
        }
    }

    @ViewBuilder
    func emptyView(width: CGFloat, height: CGFloat) -> some View {
        EmptyPanda(
            .Teacher,
            title: Text("No Courses", bundle: .core),
            message: Text(
                "It looks like there aren’t any courses associated with this account. Visit the web to create a course today.",
                bundle: .core
            )
        )
        .frame(minWidth: width, minHeight: height)
    }

    @ViewBuilder
    func errorView(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Text("Something went wrong", bundle: .core)
                .font(.regular16).foregroundColor(.textDanger)
                .multilineTextAlignment(.center)
        }
        .frame(minWidth: width, minHeight: height)
    }

    @ViewBuilder
    func courseAndGroupList(sections: AllCoursesSections) -> some View {
        if !sections.courses.isEmpty {
            Spacer(minLength: 16)
            Text("Courses", bundle: .core)
                .font(.heavy24).foregroundColor(.textDarkest)
                .accessibility(addTraits: .isHeader)
                .padding(.leading, 16)
                .padding(.trailing, 16)
            Spacer(minLength: 16)
            Divider()
            Spacer()
            Text("Select courses for Dashboard or navigate to course details.", bundle: .core)
                .font(.regular16).foregroundColor(.textDarkest)
                .accessibility(addTraits: .isHeader)
                .padding(.leading, 16)
                .padding(.trailing, 16)
            Spacer()
            courseSection(
                header: Text("Current Enrollments", bundle: .core),
                courses: sections.courses.current
            )
            courseSection(
                header: Text("Past Enrollments", bundle: .core),
                courses: sections.courses.past
            )
            courseSection(
                header: Text("Future Enrollments", bundle: .core),
                courses: sections.courses.future
            )
        }

        if !sections.groups.isEmpty {
            Divider()
            Spacer(minLength: 16)
            Text("Groups", bundle: .core)
                .font(.heavy24).foregroundColor(.textDarkest)
                .accessibility(addTraits: .isHeader)
                .padding(.leading, 16)
                .padding(.trailing, 16)
            Spacer(minLength: 16)
            Divider()
            Spacer()
            Text("Select groups for Dashboard or navigate to group details.", bundle: .core)
                .font(.regular16).foregroundColor(.textDarkest)
                .accessibility(addTraits: .isHeader)
                .padding(.leading, 16)
                .padding(.trailing, 16)
            Spacer()
            Divider()
            groupSection(sections.groups)
            Divider()
        }
    }

    @ViewBuilder
    func groupSection(_ groups: [AllCoursesGroupItem]) -> some View {
        if !groups.isEmpty {
            ForEach(groups, id: \.id) { group in
                if group.id != groups.first?.id { Divider() }
                AllCoursesCellView(
                    viewModel: AllCoursesAssembly.makeCourseCellViewModel(with: .group(group), env: .shared)
                )
            }
        }
    }

    @ViewBuilder
    func courseSection(header: Text, courses: [AllCoursesCourseItem]) -> some View {
        if !courses.isEmpty {
            Section(header: ListSectionHeaderOld(isLarge: true) { header }) {
                ForEach(courses, id: \.courseId) { course in
                    if course.courseId != courses.first?.courseId { Divider() }
                    AllCoursesCellView(
                        viewModel: AllCoursesAssembly.makeCourseCellViewModel(with: .course(course), env: .shared)
                    )
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
