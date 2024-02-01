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

import SwiftUI

struct AssignmentRemindersView: View {
    @ScaledMetric private var uiScale: CGFloat = 1
    @StateObject private var viewModel: AssignmentRemindersViewModel

    init(viewModel: (@escaping () -> AssignmentRemindersViewModel)) {
        self._viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            reminderItemList
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .confirmationAlert(isPresented: $viewModel.showingDeleteConfirmDialog,
                           presenting: viewModel.confirmAlert)
        .animation(.default, value: viewModel.reminders)
    }

    @ViewBuilder
    private var reminderItemList: some View {
        ForEach(viewModel.reminders) { reminderModel in
            AssignmentReminderItemView(viewModel: reminderModel,
                                       deleteDidTap: {
                                           viewModel.reminderDeleteDidTap(reminderModel)
                                       })
            .transition(.asymmetric(insertion: .opacity, removal: .move(edge: .trailing)))
        }
    }

    private var header: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Reminder")
                    .foregroundStyle(Color.textDark)
                    .font(.regular14)
                Text("Add due date reminder notifications about this assignment on this device.")
                    .padding(.top, 4)
                    .foregroundStyle(Color.textDarkest)
                    .font(.regular16)
            }
            Spacer(minLength: 0)
            Button {
                viewModel.newReminderDidTap()
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
        }
        .padding(.bottom, 28)
        .padding(.top, 24)
    }
}

#if DEBUG

struct AssignmentRemindersView_Previews: PreviewProvider {

    static var previews: some View {
        VStack { // Preview bug, if not embedded into this the insert animation won't play
            AssignmentRemindersView(viewModel: { AssignmentRemindersViewModel() })
        }
    }
}

#endif
