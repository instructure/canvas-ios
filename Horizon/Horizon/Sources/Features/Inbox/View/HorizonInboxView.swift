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

struct HorizonInboxView: View {

    @Bindable var viewModel: HorizonInboxViewModel

    @State private var isMessagesFilterFocused: Bool = false

    var body: some View {
        VStack {
            topBar
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: HorizonUI.spaces.space16) {
                        filterSelection

                        searchFilter

                        messageList
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .onChange(of: scrollViewProxy) { proxy in

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HorizonUI.colors.surface.pagePrimary)
        .navigationBarHidden(true)
    }

    var messageList: some View {
        VStack {
            ForEach(viewModel.messageRows, id: \.self) { messageRow in
                MessageRow(viewModel: messageRow)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity)
        .background(HorizonUI.colors.surface.pageSecondary)
        .clipShape(
            .rect(
                topLeadingRadius: 32,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 32
            )
        )
    }

    var filterSelection: some View {
        HorizonUI.SingleSelect(
            selection: $viewModel.filter,
            focused: $isMessagesFilterFocused,
            label: nil,
            options: HorizonInboxViewModel.FilterOption.allCases.map { $0.title },
            zIndex: 102
        )
        .padding(.horizontal, .huiSpaces.space16)
    }

    var searchFilter: some View {
        HorizonUI.MultiSelect(
            selections: $viewModel.searchByPersonSelections,
            focused: $viewModel.isSearchFocused,
            label: nil,
            textInput: $viewModel.searchString,
            options: viewModel.personOptions,
            loading: $viewModel.searchLoading,
            placeholder: String(localized: "Filter by person", bundle: .horizon)
        )
        .padding(.horizontal, .huiSpaces.space16)
    }

    var topBar: some View {
        HStack {
            HorizonBackButton(onBack: viewModel.goBack)
            Spacer()
            HorizonUI.PrimaryButton(
                String(localized: "Create message", bundle: .horizon),
                type: .institution,
                leading: HorizonUI.icons.editSquare
            ) { }
        }
        .padding(.horizontal, .huiSpaces.space16)
    }
}

struct MessageRow: View {

    var viewModel: HorizonInboxViewModel.MessageRowViewModel

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(viewModel.date)
                    .huiTypography(.p2)
                    .padding(.bottom, .huiSpaces.space8)

                Spacer()

                if viewModel.isNew {
                    newIndicatorBadge
                }
            }

            Text(viewModel.subject)
                .huiTypography(.labelMediumBold)

            Text(viewModel.names)
                .huiTypography(.labelMediumBold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space12)
        .padding(.leading, .huiSpaces.space16)
        .padding(.trailing, .huiSpaces.space12)
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
    HorizonInboxView(
        viewModel: HorizonInboxViewModel()
    )
}
