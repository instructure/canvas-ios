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
    let isFavoriteButtonHidden: Bool

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var pending: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Button(action: toggleFavorite) {
                let icon = pending ? Image.starSolid.foregroundColor(.textDark) :
                    course.isFavorite ? Image.starSolid.foregroundColor(.textInfo) :
                    Image.starLine.foregroundColor(.textDark)
                icon
                    .frame(width: 20, height: 20)
                    .padding(EdgeInsets(top: Typography.Spacings.textCellIconTopPadding,
                                        leading: Typography.Spacings.textCellIconLeadingPadding, bottom: 0,
                                        trailing: Typography.Spacings.textCellIconTrailingPadding))
            }
                .buttonStyle(PlainButtonStyle())
                .accessibility(label: pending ? Text("Updating", bundle: .core) : Text("favorite", bundle: .core))
                .accessibility(addTraits: (course.isFavorite && !pending) ? .isSelected : [])
                .hidden(isFavoriteButtonHidden)

            Button(action: {
                env.router.route(to: "/courses/\(course.id)", from: controller)
            }) { HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(course.name ?? "")
                        .style(.textCellTitle)
                        .foregroundColor(.textDarkest)
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
                    .style(.textCellSupportingText)
                    .foregroundColor(.textDark)
                }
                .padding(.top, Typography.Spacings.textCellTopPadding)
                .padding(.bottom, Typography.Spacings.textCellTopPadding)

                if course.hasTeacherEnrollment {
                    let icon = course.isPublished ? Image.completeSolid.foregroundColor(.textSuccess) :
                        Image.noSolid.foregroundColor(.textDark)
                    icon.padding(16)
                } else {
                    DisclosureIndicator().padding(16)
                }
            } }
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

#if DEBUG

struct CourseListCell_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext

    static var previews: some View {
        CourseListCell(course: Course.save(.make(), in: context), isFavoriteButtonHidden: false)
            .previewLayout(.sizeThatFits)
    }
}

#endif
