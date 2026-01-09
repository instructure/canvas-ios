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
    // MARK: - Propertites a11y
    @AccessibilityFocusState private var focusedFilterSelection: Bool?
    @AccessibilityFocusState private var focusedFilterPeople: Bool?
    @AccessibilityFocusState private var messageFocusedID: String?
    @State private var lastFocusedMessageID: String?

    @Environment(\.viewController) private var viewController
    @Bindable var viewModel: HInboxViewModel
    let coordinateSpaceName: String = "scroll"

    var body: some View {
        GeometryReader { scrollViewProxy in
            InstUI.BaseScreen(
                state: viewModel.screenState,
                config: .init(refreshable: true),
                refreshAction: viewModel.refresh
            ) { _ in
                VStack(alignment: .leading, spacing: HorizonUI.spaces.space8) {
                    filterSelection
                    peopleSelection
                    messageList
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityHidden(viewModel.peopleSelectionViewModel.isFocused)

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
        .overlay { loaderView }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HorizonUI.colors.surface.pagePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .top, spacing: .zero) { topBar }
        .navigationBarHidden(true)
        .onTapGesture {
            ScrollOffsetReader.dismissKeyboard()
        }
        .onFirstAppear {
            viewModel.refresh {}
        }
        .onAppear {
            if let lastFocusedMessageID {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    messageFocusedID = lastFocusedMessageID
                }
            }
        }
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            ZStack {
                Color.huiColors.surface.pageSecondary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
                    .accessibilityLabel("Loading notifications")
            }
        }
    }

    private var messageList: some View {
        VStack(spacing: .zero) {
            ForEach(viewModel.messageRows, id: \.id) { messageRow in
                MessageRow(viewModel: messageRow) {
                    lastFocusedMessageID = messageRow.id
                    viewModel.viewMessage(
                        announcement: messageRow.announcement,
                        inboxMessageListItem: messageRow.inboxMessageListItem,
                        viewController: viewController
                    )
                }
                .id(messageRow.id)
                .accessibilityFocused($messageFocusedID, equals: messageRow.id)
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
        .accessibilityHidden(viewModel.isMessagesFilterFocused || (viewModel.filterTitle == HInboxViewModel.FilterOption.announcements.title))
        .accessibilityFocused($focusedFilterPeople, equals: true)
        .onChange(of: viewModel.peopleSelectionViewModel.isFocused) { _, newValue in
            if newValue == false {
                focusedFilterPeople = true
            }
        }
    }

    private var filterSelection: some View {
        HorizonUI.SingleSelect(
            selection: $viewModel.filterTitle,
            focused: $viewModel.isMessagesFilterFocused,
            isSearchable: false,
            label: nil,
            options: HInboxViewModel.FilterOption.allCases.map { $0.title },
            zIndex: 102
        )
        .padding(.horizontal, HorizonUI.spaces.space12)
        .accessibilityFocused($focusedFilterSelection, equals: true)
        .onChange(of: viewModel.isMessagesFilterFocused) { _, newValue in
            if newValue == false {
                focusedFilterSelection = true
            }
        }
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
            .hidden(viewModel.isLoaderVisible)
        }
        .padding(.huiSpaces.space16)
    }
}

struct MessageRow: View {
    let viewModel: HInboxViewModel.MessageRowViewModel
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.isNew || !viewModel.dateString.isEmpty {
                HStack(alignment: .top) {
                    Text(viewModel.dateString)
                        .huiTypography(.p2)
                        .padding(.bottom, .huiSpaces.space8)

                    Spacer()

                    if viewModel.isNew {
                        newIndicatorBadge
                    }
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
                        .lineLimit(1)
                        .huiTypography(viewModel.isNew ? .labelMediumBold : .p2)

                    Text(viewModel.subtitle)
                        .lineLimit(1)
                        .huiTypography(viewModel.isNew ? .labelMediumBold : .p2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space12)
        .padding(.leading, .huiSpaces.space16)
        .padding(.trailing, .huiSpaces.space12)
        .background(HorizonUI.colors.surface.pageSecondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .contentShape(.rect)
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

    private var accessibilityLabel: String {
        var parts: [String] = []

        if viewModel.isNew {
            parts.append(String(localized: "New message"))
        }

        if !viewModel.dateString.isEmpty {
            parts.append(String(format: String(localized: "Date %@"), viewModel.dateString))
        }

        if viewModel.isAnnouncementIconVisible {
            parts.append(viewModel.title)
            parts.append(String(format: String(localized: "Subject %@"), viewModel.subtitle))
        } else {
            parts.append(String(format: String(localized: "Subject %@"), viewModel.title))
            parts.append(String(format: String(localized: "Sender %@"), viewModel.subtitle))
        }

        return parts.joined(separator: ", ")
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
