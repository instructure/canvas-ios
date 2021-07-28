//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct K5ScheduleEntryView: View {
    @ObservedObject private var viewModel: K5ScheduleEntryViewModel

    public init(viewModel: K5ScheduleEntryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Button(action: viewModel.actionTriggered, label: {
            HStack(spacing: 0) {
                leading
                icon

                VStack(alignment: .leading, spacing: 0) {
                    title

                    if let subtitleModel = viewModel.subtitle {
                        subtitle(model: subtitleModel)
                    }

                    if !viewModel.labels.isEmpty {
                        labels
                    }
                }
                .padding(.leading, 12)
                .padding(.vertical, 8)

                VStack(alignment: .trailing) {
                    if let scoreText = viewModel.score {
                        score(text: scoreText)
                    }

                    due
                }
                .padding(.leading, 8)
                .padding(.vertical, 8)

                disclosureIndicator
            }
            .padding(.trailing, 11)
        })
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var leading: some View {
        switch viewModel.leading {
        case .warning:
            Image.warningLine
                .foregroundColor(.crimson)
                .padding(.leading, 20)
                .padding(.trailing, 20)
        case .checkbox(let isChecked):
            checkBox(isChecked: isChecked)
        }
    }

    private var icon: some View {
        viewModel.icon
            .foregroundColor(.licorice)
    }

    private var title: some View {
        Text(viewModel.title)
            .foregroundColor(.textDarkest)
            .font(.regular17)
    }

    private var disclosureIndicator: some View {
        Image.arrowOpenRightSolid
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundColor(.ash)
            .padding(.leading, 10)
    }

    private var labels: some View {
        HStack(spacing: 4) {
            ForEach(viewModel.labels) {
                Text($0.text)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    .padding(.bottom, 3)
                    .foregroundColor($0.color)
                    .font(.regular12)
                    .background(Capsule().stroke($0.color))
            }
        }
        .padding(.bottom, 7)
        .padding(.top, 7)
    }

    private var due: some View {
        Text(viewModel.dueText)
            .font(.regular12)
            .foregroundColor(.ash)
    }

    private func score(text: String) -> some View {
        Text(text)
            .font(.bold17)
            .foregroundColor(.licorice)
    }

    private func checkBox(isChecked: Bool) -> some View {
        Button(action: viewModel.checkboxTapped, label: {
            // This allows the hit area to be big while keeping the icon normal sized
            let background = Color.clear
                .frame(width: 60)
                .frame(maxHeight: .infinity)

            if isChecked {
                background.overlay(Image.filterCheckbox)
            } else {
                let icon = RoundedRectangle(cornerRadius: 3).stroke(Color.licorice, lineWidth: 1).frame(width: 21, height: 21)
                background.overlay(icon)
            }
        })
    }

    private func subtitle(model: K5ScheduleEntryViewModel.SubtitleViewModel) -> some View {
        Text(model.text)
            .foregroundColor(model.color)
            .font(model.font)
            .padding(.top, 4)
    }
}

#if DEBUG

struct K5ScheduleEntryView_Previews: PreviewProvider {
    private static let models: [K5ScheduleEntryViewModel] = [
        K5ScheduleEntryViewModel(
            leading: .checkbox(isChecked: false),
            icon: .calendarTab,
            title: "I created this todo for today",
            subtitle: nil,
            labels: [],
            score: nil,
            dueText: "To Do: 1:59 PM",
            checkboxChanged: nil,
            action: {}),
        K5ScheduleEntryViewModel(
            leading: .checkbox(isChecked: true),
            icon: .assignmentLine,
            title: "Attributes of Polygons",
            subtitle: .init(text: "You've marked it as done", color: .ash, font: .regular12),
            labels: [
                .init(text: "REPLIES", color: .ash),
                .init(text: "REDO", color: .crimson),
            ],
            score: "5 pts",
            dueText: "Due: 11:59 PM",
            checkboxChanged: nil,
            action: {}),
        K5ScheduleEntryViewModel(
            leading: .warning,
            icon: .assignmentLine,
            title: "Identifying Physical Changes I.",
            subtitle: .init(text: "SCIENCE", color: Color(hexString: "#8BD448")!, font: .regular10),
            labels: [],
            score: "5 pts",
            dueText: "Due Yesterday",
            checkboxChanged: nil,
            action: {}),
    ]

    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = setupK5Mode()
        ForEach(models) {
            K5ScheduleEntryView(viewModel: $0).previewLayout(.sizeThatFits)
        }
    }

    private static func setupK5Mode() {
        let session = LoginSession(
            accessToken: "token",
            baseURL: URL(string: "https://canvas.instructure.com")!,
            expiresAt: nil,
            lastUsedAt: Date(),
            locale: "en",
            masquerader: nil,
            refreshToken: nil,
            userAvatarURL: nil,
            userID: "1",
            userName: "Eve",
            userEmail: nil,
            clientID: nil,
            clientSecret: nil
        )
        AppEnvironment.shared.userDidLogin(session: session)
        AppEnvironment.shared.k5.userDidLogin(isK5Account: true)
        AppEnvironment.shared.userDefaults?.isElementaryViewEnabled = true
        ExperimentalFeature.K5Dashboard.isEnabled = true
    }
}

#endif
