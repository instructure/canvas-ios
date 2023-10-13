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
    @StateObject private var offlineStateViewModel: CourseListCellOfflineStateViewModel

    private var isCellDisabled: Bool {
        !course.isCourseDetailsAvailable || !offlineStateViewModel.isCourseEnabled
    }

    init(course: CourseListItem) {
        self.course = course
        self._offlineStateViewModel = StateObject(wrappedValue: .init(courseId: course.courseId,
                                                                      offlineModeInteractor: OfflineModeAssembly.make(),
                                                                      sessionDefaults: AppEnvironment.shared.userDefaults ?? .fallback))
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Button(action: toggleFavorite) {
                let icon = pending ? Image.starSolid.foregroundColor(.textDark) :
                    course.isFavorite ? Image.starSolid.foregroundColor(.textInfo) :
                    Image.starLine.foregroundColor(.textDark)
                icon
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 18)
            }
                .buttonStyle(PlainButtonStyle())
                .accessibility(label: pending ? Text("Updating", bundle: .core) : Text("favorite", bundle: .core))
                .accessibilityIdentifier("DashboardCourseCell.\(course.courseId).favoriteButton")
                .accessibility(addTraits: (course.isFavorite && !pending) ? .isSelected : [])
                .hidden(!course.isFavoriteButtonVisible)
                .disabled(offlineStateViewModel.isFavoriteStarDisabled)

            Button {
                env.router.route(to: "/courses/\(course.courseId)", from: controller)
            } label: {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(course.name)
                            .font(.semibold16, lineHeight: .fit)
                            .foregroundColor(isCellDisabled ? .textDark : .textDarkest)
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
                    .padding(.trailing, 16)

                    if offlineStateViewModel.isOfflineIndicatorVisible {
                        Image.circleArrowDownSolid
                            .resizable()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.textDark)
                            .padding(3)
                            .padding(.trailing, 8)
                    }

                    if AppEnvironment.shared.app == .teacher {
                        let icon = course.isPublished ? Image.completeSolid.foregroundColor(.textSuccess) :
                        Image.noSolid.foregroundColor(.textDark)
                        icon.padding(.trailing, 16)
                    } else {
                        InstDisclosureIndicator()
                            .padding(.trailing, 16)
                            .hidden(isCellDisabled)
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: accessibilityLabel)
            .accessibilityIdentifier("DashboardCourseCell.\(course.courseId)")
            .disabled(isCellDisabled)
        }
        .padding(.leading, 22)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .frame(minHeight: 72)
    }

    var accessibilityLabel: Text {
        let offlineLabel = offlineStateViewModel.isOfflineIndicatorVisible ? NSLocalizedString("Available offline", comment: "")
        : nil
        return Text([
            course.name,
            course.termName,
            course.roles,
            offlineLabel,
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
        VStack(spacing: 0) {
            Divider()
            CourseListCell(course: CourseListItem.save(.make(id: "1", workflow_state: .available),
                                                       enrollmentState: .active,
                                                       app: .student,
                                                       in: context))
            Divider()
            CourseListCell(course: CourseListItem.save(.make(id: "2", workflow_state: .unpublished),
                                                       enrollmentState: .active,
                                                       app: .student,
                                                       in: context))
            Divider()
        }
        .previewLayout(.sizeThatFits)
    }
}

#endif
