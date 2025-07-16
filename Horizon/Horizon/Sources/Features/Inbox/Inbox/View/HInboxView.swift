//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import Combine
import HorizonUI
import SwiftUI

struct HInboxView: View {

    @Environment(\.viewController) private var viewController
    @Bindable var viewModel: HInboxViewModel
    let coordinateSpaceName: String = "scroll"

    var body: some View {
            VStack {
                topBar
                GeometryReader { scrollViewProxy in
                    InstUI.BaseScreen(
                        state: viewModel.screenState,
                        config: .init(refreshable: true),
                        refreshAction: viewModel.refresh
                    ) { _ in
                        VStack(alignment: .leading, spacing: HorizonUI.spaces.space12) {
                            filterSelection

                            peopleSelection

                            messageArea
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            GeometryReader { contentProxy in
                                Color.clear
                                    .onChange(of: contentProxy.frame(in: .named(coordinateSpaceName)).minY) {
                                        viewModel.loadMoreIfScrolledEnough(
                                            scrollViewProxy: scrollViewProxy,
                                            contentProxy: contentProxy,
                                            coordinateSpaceName: coordinateSpaceName
                                        )
                                    }
                            }
                        )
                }
                .coordinateSpace(name: coordinateSpaceName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(HorizonUI.colors.surface.pagePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
    }

    private var messageArea: some View {
        ZStack {
            HorizonUI.Spinner(size: .xSmall)
                .opacity(viewModel.spinnerOpacity)
                .animation(.easeInOut(duration: 0.2), value: viewModel.spinnerOpacity)
            messageList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var messageList: some View {
        VStack(spacing: .zero) {
            ForEach(viewModel.messageRows, id: \.id) { messageRow in
                MessageRow(viewModel: messageRow) {
                    viewModel.viewMessage(
                        announcement: messageRow.announcement,
                        inboxMessageListItem: messageRow.inboxMessageListItem,
                        viewController: viewController
                    )
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(HorizonUI.colors.surface.pageSecondary)
        .opacity(viewModel.messageListOpacity)
        .animation(.easeInOut(duration: 0.2), value: viewModel.messageListOpacity)
        .clipShape(
            .rect(
                topLeadingRadius: HorizonUI.CornerRadius.level4.attributes.radius,
                topTrailingRadius: HorizonUI.CornerRadius.level4.attributes.radius
            )
        )
    }

    private var peopleSelection: some View {
        RecipientSelectionView(
            viewModel: viewModel.peopleSelectionViewModel,
            placeholder: String(localized: "Filter by person", bundle: .horizon),
            disabled: viewModel.isSearchDisabled
        )
        .padding(.horizontal, HorizonUI.spaces.space12)
    }

    private var filterSelection: some View {
        HorizonUI.SingleSelect(
            selection: $viewModel.filterTitle,
            focused: $viewModel.isMessagesFilterFocused,
            label: nil,
            options: HInboxViewModel.FilterOption.allCases.map { $0.title },
            zIndex: 102
        )
        .padding(.horizontal, HorizonUI.spaces.space12)
    }

    private var topBar: some View {
        HStack {
            HorizonBackButton(onBack: viewModel.goBack)
            Spacer()
            HorizonUI.PrimaryButton(
                String(localized: "Create message", bundle: .horizon),
                type: .institution,
                leading: HorizonUI.icons.editSquare
            ) {
                viewModel.goToComposeMessage(viewController)
            }
        }
        .padding(.horizontal, .huiSpaces.space16)
    }
}

struct MessageRow: View {

    let viewModel: HInboxViewModel.MessageRowViewModel
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(viewModel.dateString)
                    .huiTypography(.p2)
                    .padding(.bottom, .huiSpaces.space8)

                Spacer()

                if viewModel.isNew {
                    newIndicatorBadge
                }
            }

            HStack(alignment: .top, spacing: .huiSpaces.space8) {
                if viewModel.isAnnouncementIconVisible {
                    HorizonUI.icons.announcement
                        .renderingMode(.template)
                        .foregroundStyle(HorizonUI.colors.icon.default)
                }
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .huiTypography(.labelMediumBold)

                    Text(viewModel.subtitle)
                        .huiTypography(.labelMediumBold)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space12)
        .padding(.leading, .huiSpaces.space16)
        .padding(.trailing, .huiSpaces.space12)
        .background(HorizonUI.colors.surface.pageSecondary)
        .onTapGesture {
            onTap()
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(HorizonUI.colors.lineAndBorders.lineStroke),
            alignment: .bottom
        )
    }

    var newIndicatorBadge: some View {
        HStack {}
            .frame(width: HorizonUI.spaces.space8, height: HorizonUI.spaces.space8)
            .background(HorizonUI.colors.surface.institution)
            .clipShape(Circle())
    }
}

struct AddressbookInteractorPreview: AddressbookInteractor {
    var state: CurrentValueSubject<StoreState, Never> {
        CurrentValueSubject(.data)
    }
    var recipients: CurrentValueSubject<[SearchRecipient], Never> {
        CurrentValueSubject([])
    }
    var canSelectAllRecipient: CurrentValueSubject<Bool, Never> {
        CurrentValueSubject(false)
    }

    func refresh() -> Future<Void, Never> {
        Future { promise in
            promise(.success(()))
        }
    }

    func setSearch(_ searchString: String) {
    }
}

#Preview {
    HInboxView(
        viewModel: HInboxViewModel()
    )
}
