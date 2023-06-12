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
    @ObservedObject var course: CourseListItem

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
                .accessibilityIdentifier("DashboardCourseCell.\(course.courseId).favoriteButton")
                .accessibility(addTraits: (course.isFavorite && !pending) ? .isSelected : [])
                .hidden(!course.isFavoriteButtonVisible)

            Button(action: {
                env.router.route(to: "/courses/\(course.courseId)", from: controller)
            }) { HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(course.name)
                        .style(.textCellTitle)
                        .foregroundColor(course.isCourseDetailsAvailable ? .textDarkest : .textDark)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 8) {
                        course.termName.map { Text($0) }
                        if course.termName != nil, !course.roles.isEmpty {
                            Text(verbatim: "|")
                        }
                        Text(course.roles)
                        Spacer()
                    }
                    .style(.textCellSupportingText)
                    .foregroundColor(.textDark)
                }
                .padding(.top, Typography.Spacings.textCellTopPadding)
                .padding(.bottom, Typography.Spacings.textCellTopPadding)

                if AppEnvironment.shared.app == .teacher {
                    let icon = course.isPublished ? Image.completeSolid.foregroundColor(.textSuccess) :
                        Image.noSolid.foregroundColor(.textDark)
                    icon.padding(16)
                } else {
                    if course.isCourseDetailsAvailable {
                        DisclosureIndicator().padding(16)
                    }
                }
            } }
            .accessibilityElement(children: .ignore)
            .accessibility(label: accessibilityLabel)
            .accessibilityIdentifier("DashboardCourseCell.\(course.courseId)")
            .disabled(!course.isCourseDetailsAvailable)
        }
    }

    var accessibilityLabel: Text {
        Text([
            course.name,
            course.termName,
            course.roles,
            !(AppEnvironment.shared.app == .teacher) ? nil : course.isPublished ?
                NSLocalizedString("published", comment: "") :
                NSLocalizedString("unpublished", comment: ""),
        ].compactMap { $0 }.joined(separator: ", "))
    }

    func toggleFavorite() {
        guard !pending else { return }
        withAnimation { pending = true }
        MarkFavoriteCourse(courseID: course.courseId, markAsFavorite: !course.isFavorite).fetch { _, _, _ in
            withAnimation { pending = false }
        }
    }
}

#if DEBUG

struct CourseListCell_Previews: PreviewProvider {
    private static let env = PreviewEnvironment()
    private static let context = env.globalDatabase.viewContext

    static var previews: some View {
        CourseListCell(course: CourseListItem.save(.make(), enrollmentState: .active, in: context))
            .previewLayout(.sizeThatFits)
    }
}

#endif
