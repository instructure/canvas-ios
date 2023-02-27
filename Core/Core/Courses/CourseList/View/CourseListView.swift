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

public struct CourseListView: View, ScreenViewTrackable {
    @ObservedObject private var viewModel: CourseListViewModel
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/courses")
    static var searchBarHeight: CGFloat = UISearchBar().sizeThatFits(.zero).height

    public init(viewModel: CourseListViewModel) {
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
                    case .data:
                        ScrollViewReader { scrollView in
                            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
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
                                Divider().id(0) // target to scroll passed search
                                list(height, sections: viewModel.sections)
                            }
                            .onAppear { scrollView.scrollTo(0, anchor: .bottom) }
                        }
                    case .empty:
                        EmptyPanda(.Teacher,
                                   title: Text("No Courses", bundle: .core),
                                   message: Text("It looks like there aren’t any courses associated with this account. Visit the web to create a course today.", bundle: .core))
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
    func list(_ height: CGFloat, sections: CourseListSections) -> some View {
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
        let courses: [CourseListItem]

        var body: some View {
            if !courses.isEmpty {
                Section(header: ListSectionHeader { header }) {
                    ForEach(courses, id: \.courseId) { course in
                        if course.courseId != courses.first?.courseId { Divider() }
                        CourseListCell(course: course)
                    }
                }
            }
        }
    }
}

#if DEBUG

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListAssembly.makePreview()
    }
}

#endif
