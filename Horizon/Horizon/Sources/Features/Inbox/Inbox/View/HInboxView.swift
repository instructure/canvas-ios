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

    var body: some View {
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HorizonUI.colors.surface.pagePrimary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .top, spacing: .zero) { topBar }
        .navigationBarHidden(true)
        .onTapGesture {
            ScrollOffsetReader.dismissKeyboard()
        }
        .onAppear {
            if let lastFocusedMessageID {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    messageFocusedID = lastFocusedMessageID
                }
            }
        }
    }

    private var messageList: some View {
        LazyVStack(spacing: .zero) {
            ForEach(viewModel.messageRows, id: \.id) { messageRow in
                InboxMessageView(viewModel: messageRow) {
                    lastFocusedMessageID = messageRow.id
                    viewModel.viewMessage(
                        announcement: messageRow.announcement,
                        messageID: messageRow.messageListItemID,
                        viewController: viewController
                    )
                }
                .id(messageRow.id)
                .accessibilityFocused($messageFocusedID, equals: messageRow.id)
                .onAppear { viewModel.loadMore(message: messageRow) }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(HorizonUI.colors.surface.pageSecondary)
        .hidden(viewModel.messageRows.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: viewModel.messageRows.count)
        .roundedTopCorners()
    }

    private var peopleSelection: some View {
        RecipientSelectionView(
            viewModel: viewModel.peopleSelectionViewModel,
            placeholder: String(localized: "Filter by person", bundle: .horizon),
            disabled: viewModel.isSearchDisabled
        )
        .padding(.horizontal, HorizonUI.spaces.space12)
        .accessibilityHidden(viewModel.isMessagesFilterFocused || (viewModel.filterTitle == InboxFilterOption.announcements.title))
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
            options: InboxFilterOption.allCases.map { $0.title },
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
            .hidden(viewModel.screenState == .loading)
        }
        .padding(.huiSpaces.space16)
    }
}

#if DEBUG
#Preview {
    HInboxAssembly.preview()
}
#endif
