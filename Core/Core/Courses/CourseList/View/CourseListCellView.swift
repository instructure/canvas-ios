//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct CourseListCell: View {
    @ObservedObject var course: Course

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var pending: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Button(action: toggleFavorite) {
                let icon = pending ? Image.starSolid.foregroundColor(.textDark) :
                    course.isFavorite ? Image.starSolid.foregroundColor(.textInfo) :
                    Image.starLine.foregroundColor(.textDark)
                icon.padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 12))
            }
                .buttonStyle(PlainButtonStyle())
                .accessibility(label: pending ? Text("Updating", bundle: .core) : Text("favorite", bundle: .core))
                .accessibility(addTraits: (course.isFavorite && !pending) ? .isSelected : [])
                .hidden(course.isPastEnrollment)

            Button(action: {
                env.router.route(to: "/courses/\(course.id)", from: controller)
            }, label: { HStack {
                VStack(alignment: .leading) {
                    Text(course.name ?? "")
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 8) {
                        let role = course.enrollments?.first { $0.state != .deleted }?.formattedRole
                        course.termName.map { Text($0) }
                        if course.termName != nil && role != nil {
                            Text(verbatim: "|")
                        }
                        role.map { Text($0) }
                        Spacer()
                    }
                        .font(.medium14).foregroundColor(.textDark)
                }
                    .padding(.vertical, 16)

                if course.hasTeacherEnrollment {
                    let icon = course.isPublished ? Image.completeSolid.foregroundColor(.textSuccess) :
                        Image.noSolid.foregroundColor(.textDark)
                    icon.padding(16)
                } else {
                    DisclosureIndicator().padding(16)
                }
            } })
                .accessibilityElement(children: .ignore)
                .accessibility(label: accessibilityLabel)
        }
        .accessibility(identifier: "DashboardCourseCell.\(course.id)")
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
