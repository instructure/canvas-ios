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

struct AllCoursesCellView: View {
    enum Item {
        case course(AllCoursesCourseItem)
        case group(AllCoursesGroupItem)
    }

    // MARK: - Dependencies

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    private let item: Item

    // MARK: - Private properties

    @State private var pending: Bool = false
    @StateObject private var offlineStateViewModel: AllCoursesCellOfflineStateViewModel

    private var isCellDisabled: Bool {
        !item.isDetailsAvailable || !offlineStateViewModel.isItemEnabled
    }

    // MARK: - Init

    init(item: Item) {
        self.item = item
        _offlineStateViewModel = StateObject(
            wrappedValue: .init(
                item: item,
                offlineModeInteractor: OfflineModeAssembly.make(),
                sessionDefaults: AppEnvironment.shared.userDefaults ?? .fallback
            )
        )
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            favoriteButton
            Button {
                env.router.route(to: item.path, from: controller)
            } label: {
                HStack(spacing: 0) {
                    itemDetailsView
                    offlineButton
                    disclosureView
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: accessibilityLabel)
            .accessibilityIdentifier("DashboardCourseCell.\(item.id)")
            .disabled(isCellDisabled)
        }
        .padding(.leading, 22)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .frame(minHeight: 72)
    }

    @ViewBuilder
    var favoriteButton: some View {
        Button(action: toggleFavorite) {
            let icon = pending ? Image.starSolid.foregroundColor(.textDark) :
                item.isFavourite ? Image.starSolid.foregroundColor(.textInfo) :
                Image.starLine.foregroundColor(.textDark)
            icon
                .frame(width: 20, height: 20)
                .padding(.trailing, 18)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: pending ? Text("Updating", bundle: .core) : Text("favorite", bundle: .core))
        .accessibilityIdentifier("DashboardCourseCell.\(item.id).favoriteButton")
        .accessibility(addTraits: (item.isFavourite && !pending) ? .isSelected : [])
        .hidden(!item.isFavoriteButtonVisible)
        .disabled(offlineStateViewModel.isFavoriteStarDisabled)
    }

    @ViewBuilder
    var itemDetailsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(item.name)
                .font(.semibold16, lineHeight: .fit)
                .foregroundColor(isCellDisabled ? .textDark : .textDarkest)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let termName = item.termName {
                HStack(spacing: 8) {
                    Text(termName)
                    if let roles = item.roles, !roles.isEmpty {
                        Text(verbatim: "|")
                        Text(roles)
                        Spacer()
                    }
                }
                .style(.textCellSupportingText)
                .foregroundColor(.textDark)
            }
        }
        .padding(.trailing, 16)
    }

    @ViewBuilder
    var offlineButton: some View {
        if offlineStateViewModel.isOfflineIndicatorVisible {
            Image.circleArrowDownSolid
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundColor(.textDark)
                .padding(3)
                .padding(.trailing, 8)
        }
    }

    @ViewBuilder
    var disclosureView: some View {
        if AppEnvironment.shared.app == .teacher {
            let icon = item.isPublished ? Image.completeSolid.foregroundColor(.textSuccess) :
                Image.noSolid.foregroundColor(.textDark)
            icon.padding(.trailing, 16)
        } else {
            InstDisclosureIndicator()
                .padding(.trailing, 16)
                .hidden(isCellDisabled)
        }
    }

    @ViewBuilder
    var accessibilityLabel: Text {
        let offlineLabel = offlineStateViewModel.isOfflineIndicatorVisible ? NSLocalizedString("Available offline", comment: "")
            : nil
        Text([
            item.name,
            item.termName,
            item.roles,
            offlineLabel,
            !(AppEnvironment.shared.app == .teacher) ? nil : item.isPublished ?
                NSLocalizedString("published", comment: "") :
                NSLocalizedString("unpublished", comment: ""),
        ].compactMap { $0 }.joined(separator: ", "))
    }

    func toggleFavorite() {
        guard !pending else { return }
        withAnimation { pending = true }
        switch item {
        case .group:
            MarkFavoriteGroup(groupID: item.id, markAsFavorite: !item.isFavourite).fetch { _, _, _ in
                withAnimation { pending = false }
            }
        case .course:
            MarkFavoriteCourse(courseID: item.id, markAsFavorite: !item.isFavourite).fetch { _, _, _ in
                withAnimation { pending = false }
            }
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
            AllCoursesCellView(
                item: .course(AllCoursesCourseItem(
                    from: CDAllCoursesCourseItem.save(
                        .make(id: "1", workflow_state: .available),
                        enrollmentState: .active,
                        app: .student,
                        in: context
                    )
                )
            ))
            Divider()
            AllCoursesCellView(
                item: .course(AllCoursesCourseItem(
                    from: CDAllCoursesCourseItem.save(
                        .make(id: "2", workflow_state: .unpublished),
                        enrollmentState: .active,
                        app: .student,
                        in: context
                    )
                )
            ))
            Divider()
            AllCoursesCellView(
                item: .group(AllCoursesGroupItem(
                    from: CDAllCoursesGroupItem.save(
                        .make(id: "1"),
                        in: context
                    )
                )
            ))
            Divider()
        }
        .previewLayout(.sizeThatFits)
    }
 }

 #endif

extension AllCoursesCellView.Item {
    var id: String {
        switch self {
        case let .course(course): return course.courseId
        case let .group(group): return group.id
        }
    }

    var name: String {
        switch self {
        case let .course(course): return course.name
        case let .group(group): return group.name
        }
    }

    var isFavourite: Bool {
        switch self {
        case let .course(course): return course.isFavorite
        case let .group(group): return group.isFavorite
        }
    }

    var path: String {
        switch self {
        case let .course(course): return "/courses/\(course.courseId)"
        case let .group(group): return "/groups/\(group.id)"
        }
    }

    var termName: String? {
        switch self {
        case let .course(course): return course.termName
        case let .group(group): return group.courseTermName
        }
    }

    var roles: String? {
        switch self {
        case let .course(course): return course.roles
        case let .group(group): return group.courseRoles
        }
    }

    var isPublished: Bool {
        switch self {
        case let .course(course): return course.isPublished
        case .group: return true
        }
    }

    var isFavoriteButtonVisible: Bool {
        switch self {
        case let .course(course): return course.isFavoriteButtonVisible
        case .group: return true
        }
    }

    var isDetailsAvailable: Bool {
        switch self {
        case let .course(course): return course.isCourseDetailsAvailable
        case .group: return true
        }
    }
}
