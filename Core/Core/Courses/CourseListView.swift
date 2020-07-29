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

// swiftlint:disable superfluous_disable_command
// swiftlint:disable multiple_closures_with_trailing_closure

struct CourseViewModel: Hashable, Equatable {
    let id: String
    let name: String
    let term: String
    let enrollment: String
    let isFavorite: Bool
    let isPublished: Bool

    init(id: String, name: String, term: String, enrollment: String, isFavorite: Bool, isPublished: Bool) {
        self.id = id
        self.name = name
        self.term = term
        self.enrollment = enrollment
        self.isFavorite = isFavorite
        self.isPublished = isPublished
    }

    init(course: Course) {
        self.init(
            id: course.id,
            name: course.name ?? "",
            term: "Fall 2020",
            enrollment: "Teacher",
            isFavorite: course.isFavorite,
            isPublished: true
        )
    }
}

@available(iOSApplicationExtension 13.0.0, *)
public struct CourseListView: View {
    let env = AppEnvironment.shared
    @ObservedObject var courses: PublishedStore<GetAllCourses>

    init() {
        courses = env.published(GetAllCourses())
        courses.exhaust()
    }

    public static func create() -> CourseListView {
        return CourseListView()
    }

    public var body: some View {
        return Form {
            Section(header: Text("Current Enrollments")) {
                ForEach(courses._all, id: \.self) { course in
                    Cell(course: course)
                }
            }
        }
        .navigationBarTitle("All Courses")
    }

    struct Cell: View {
        @ObservedObject var course: Course
        @State var pending = false

        func toggleFavorite() {
            guard !pending else { return }
            pending = true
            if course.isFavorite {
                RemoveFavoriteCourse(courseID: course.id).fetch { _, _, _ in
                    pending = false
                }
            } else {
                AddFavoriteCourse(courseID: course.id).fetch { _, _, _ in
                    pending = false
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
            }
        }

        var body: some View {
            ZStack {
                NavigationLink(destination: Text(course.name ?? "")) { SwiftUI.EmptyView() }
                HStack {
                    favoriteButton.buttonStyle(PlainButtonStyle())
                    VStack(alignment: .leading) {
                        Text(course.name ?? "").bold()
                        Text("FOO | BAR").foregroundColor(.named(.ash))
                    }
                    Spacer()
                    Image.icon(.complete, .solid).foregroundColor(.named(.shamrock))
                }
            }
        }
    }
}

//@available(iOSApplicationExtension 13.0.0, *)
//struct CourseListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CourseListView(courses: PublishObserver(staticContents: [
//            CourseViewModel(id: "1", name: "BIO 101", term: "Fall 2020", enrollment: "Teacher", isFavorite: true, isPublished: true),
//            CourseViewModel(id: "2", name: "BIO 102", term: "Fall 2020", enrollment: "Teacher", isFavorite: false, isPublished: false),
//        ]), storeRef: nil)
//    }
//}
