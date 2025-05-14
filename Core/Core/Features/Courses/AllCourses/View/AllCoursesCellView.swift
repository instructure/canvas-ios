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
    // MARK: - Dependencies

    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    // MARK: - Private properties

    @ObservedObject private var viewModel: AllCoursesCellViewModel

    // MARK: - Init

    init(viewModel: AllCoursesCellViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            favoriteButton
            Button {
                viewModel.cellDidTap.accept(controller)
            } label: {
                HStack(spacing: 0) {
                    itemDetailsView
                    Spacer()
                    offlineButton
                    disclosureView
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibility(label: Text(viewModel.cellAccessibilityLabelText))
            .accessibilityIdentifier("DashboardCourseCell.\(viewModel.item.id)")
            .disabled(viewModel.isCellDisabled)
        }
        .padding(.leading, 22)
        .padding(.top, 12)
        .padding(.bottom, 14)
        .frame(minHeight: 72)
    }

    @ViewBuilder
    var favoriteButton: some View {
        Button(action: {
            viewModel.toggleFavoriteDidTap.accept(())
        }) {
            let icon = viewModel.pending ? Image.starSolid.foregroundColor(.textDark) :
                viewModel.item.isFavourite ? Image.starSolid.foregroundColor(.textInfo) :
                Image.starLine.foregroundColor(.textDark)
            icon
                .frame(width: 20, height: 20)
                .padding(.trailing, 18)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibility(label: Text(viewModel.favoriteButtonAccessibilityText))
        .accessibilityIdentifier("DashboardCourseCell.\(viewModel.item.id).favoriteButton")
        .accessibility(addTraits: viewModel.favoriteButtonTraits)
        .hidden(!viewModel.item.isFavoriteButtonVisible)
        .disabled(viewModel.isFavoriteStarDisabled)
    }

    @ViewBuilder
    var itemDetailsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(viewModel.item.name)
                .font(.semibold16, lineHeight: .fit)
                .foregroundColor(viewModel.isCellDisabled ? .textDark : .textDarkest)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            if let termName = viewModel.item.termName {
                HStack(spacing: 8) {
                    Text(termName)
                    if let roles = viewModel.item.roles, !roles.isEmpty {
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
        if viewModel.isOfflineIndicatorVisible {
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
            let icon = viewModel.item.isPublished ? Image.completeSolid.foregroundColor(.textSuccess) :
                Image.noSolid.foregroundColor(.textDark)
            icon.padding(.trailing, 16)
        } else {
            InstUI.DisclosureIndicator()
                .padding(.trailing, 16)
                .hidden(viewModel.isCellDisabled)
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
                viewModel: AllCoursesCellViewModel(
                    item: .course(.make()),
                    offlineModeInteractor: OfflineModeInteractorMock(),
                    sessionDefaults: env.userDefaults ?? .fallback,
                    app: env.app,
                    router: env.router
                )
            )
            Divider()
            AllCoursesCellView(
                viewModel: AllCoursesCellViewModel(
                    item: .course(.make(isFavorite: false)),
                    offlineModeInteractor: OfflineModeInteractorMock(),
                    sessionDefaults: env.userDefaults ?? .fallback,
                    app: env.app,
                    router: env.router
                )
            )
            Divider()
            AllCoursesCellView(
                viewModel: AllCoursesCellViewModel(
                    item: .course(.make(isFavorite: false, isCourseDetailsAvailable: false)),
                    offlineModeInteractor: OfflineModeInteractorMock(),
                    sessionDefaults: env.userDefaults ?? .fallback,
                    app: env.app,
                    router: env.router
                )
            )
            Divider()
            AllCoursesCellView(
                viewModel: AllCoursesCellViewModel(
                    item: .group(.make()),
                    offlineModeInteractor: OfflineModeInteractorMock(),
                    sessionDefaults: env.userDefaults ?? .fallback,
                    app: env.app,
                    router: env.router
                )
            )
            Divider()
        }
        .previewLayout(.sizeThatFits)
    }
}

#endif
