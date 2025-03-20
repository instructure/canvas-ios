//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import SwiftUI

public struct AssignmentRemindersView: View {
    @ScaledMetric private var uiScale: CGFloat = 1
    @ObservedObject private var viewModel: AssignmentRemindersViewModel
    @Environment(\.viewController) private var viewController

    init(viewModel: AssignmentRemindersViewModel) {
        self.viewModel = viewModel
    }

    @ViewBuilder
    public var body: some View {
        if viewModel.isReminderSectionVisible {
            VStack(alignment: .leading, spacing: 0) {
                divider
                    .animation(.none, value: viewModel.reminders)
                header
                    .animation(.none, value: viewModel.reminders)
                    .padding(.horizontal, 16)
                reminderItemList
                    .padding(.horizontal, 16)
                divider
                    .padding(.bottom, 24) // To look nice when embedded into assignment details
                    .animation(.none, value: viewModel.reminders)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.backgroundLightest)
            .confirmationAlert(isPresented: $viewModel.showingDeleteConfirmDialog,
                               presenting: viewModel.confirmAlert)
            .animation(.default, value: viewModel.reminders)
            .geometryGroup()
            .onAppear {
                viewController.value.view.backgroundColor = .backgroundLightest
            }
        }
    }

    @ViewBuilder
    private var reminderItemList: some View {
        ForEach(viewModel.reminders) { reminderModel in
            AssignmentReminderItemView(viewModel: reminderModel,
                                       deleteDidTap: {
                                           viewModel.reminderDeleteDidTap(reminderModel)
                                       })
            .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .trailing)))
            .geometryGroup()
        }
    }

    @ViewBuilder
    private var header: some View {
        let title = String(localized: "Reminder", bundle: .student)
        let description = String(localized: "Add due date reminder notifications about this assignment on this device.", bundle: .student)
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .foregroundStyle(Color.textDark)
                    .font(.regular14)
                    .accessibilityIdentifier("AssignmentDetails.reminder")
                Text(description)
                    .padding(.top, 4)
                    .foregroundStyle(Color.textDarkest)
                    .font(.regular16)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                viewModel.newReminderDidTap(view: viewController.value)
            } label: {
                Image.addSolid
                    .resizable()
                    .foregroundStyle(Color.textDarkest)
                    .frame(width: uiScale.iconScale * 24,
                           height: uiScale.iconScale * 24)
                    // To increase the tap area
                    .padding(.vertical, 16)
                    .padding(.leading, 16)
            }
            .accessibilityIdentifier("AssignmentDetails.addReminder")
        }
        .padding(.bottom, 28)
        .padding(.top, 24)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityHint(description)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction {
            viewModel.newReminderDidTap(view: viewController.value)
        }
        .geometryGroup()
    }

    private var divider: some View {
        Color.borderMedium.frame(height: 0.5)
    }
}

#if DEBUG

struct AssignmentRemindersView_Previews: PreviewProvider {

    static var previews: some View {
        VStack { // Preview bug, if not embedded into this the insert animation won't play
            let viewModel = AssignmentRemindersViewModelPreview(interactor: AssignmentRemindersInteractorPreview(),
                                                                router: AppEnvironment.shared.router)
            AssignmentRemindersView(viewModel: viewModel)
        }
    }
}

#endif
