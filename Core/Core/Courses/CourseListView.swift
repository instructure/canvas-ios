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

struct CourseViewModel: Hashable, Equatable {
    let name: String
    let term: String
    let enrollment: String
    var isFavorite: Bool
    let isPublished: Bool

    init(name: String, term: String, enrollment: String, isFavorite: Bool, isPublished: Bool) {
        self.name = name
        self.term = term
        self.enrollment = enrollment
        self.isFavorite = isFavorite
        self.isPublished = isPublished
    }

    init(course: Course) {
        self.init(
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
    @ObservedObject var source: PublishObserver<[CourseViewModel]>
    var courses: [CourseViewModel] { source.model }

    public static func create() -> CourseListView {
        let store = AppEnvironment.shared.subscribe(GetAllCourses(), {})
        let source = store.observable(CourseViewModel.init(course:))

        var tick: (() -> Void)!
        tick = {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: tick)
            guard let course = store.first else { return }
            course.isFavorite = !course.isFavorite
            course.name = "\(arc4random())"
        }
        tick()

        return CourseListView(source: source)
    }

    public var body: some View {
        List {
            ForEach(courses, id: \.self) {
                Cell(course: $0)
            }
        }
    }

    struct Cell: View {
        let course: CourseViewModel

        var body: some View {
            HStack {
                if course.isFavorite {
                    Image.icon(.star, .solid).foregroundColor(.named(.electric))
                } else {
                    Image.icon(.star, .line).foregroundColor(.named(.ash))
                }
                VStack(alignment: .leading) {
                    Text(course.name).bold()
                    Text("\(course.term) | \(course.enrollment)").foregroundColor(.named(.ash))
                }
                Spacer()
                if course.isPublished {
                    Image.icon(.complete, .solid).foregroundColor(.named(.shamrock))
                } else {
                    Image.icon(.complete)
                }
            }
        }
    }
}

@available(iOSApplicationExtension 13.0.0, *)
struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView(source: PublishObserver(staticContents: [
            CourseViewModel(name: "BIO 101", term: "Fall 2020", enrollment: "Teacher", isFavorite: true, isPublished: true),
            CourseViewModel(name: "BIO 102", term: "Fall 2020", enrollment: "Teacher", isFavorite: false, isPublished: false),
        ]))
    }
}
