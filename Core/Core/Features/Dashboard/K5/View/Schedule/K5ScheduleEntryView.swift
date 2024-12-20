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
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: K5ScheduleEntryViewModel

    public init(viewModel: K5ScheduleEntryViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        HStack(spacing: 0) {
            leading

            Button(action: {
                viewModel.itemTapped(router: env.router, viewController: viewController)
            }, label: {
                HStack(spacing: 0) {
                    icon

                    VStack(alignment: .leading, spacing: 0) {
                        title

                        if let subtitleModel = viewModel.subtitle {
                            subtitle(model: subtitleModel)
                        }

                        if !viewModel.labels.isEmpty {
                            labels.textCase(.uppercase)
                        }
                    }
                    .padding(.leading, 12)
                    .padding(.vertical, 8)

                    Spacer(minLength: 0)

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
            })
            .accessibility(hint: Text("Open item details", bundle: .core))
            .disabled(!viewModel.isTappable)
        }
        .padding(.trailing, 15)
        .frame(minHeight: 66)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var leading: some View {
        switch viewModel.leading {
        case .warning:
            Image.warningLine
                .foregroundColor(.textDanger)
                .padding(.leading, 18)
                .padding(.trailing, 18)
                .accessibility(hidden: true)
        case .checkbox(let isChecked):
            checkBox(isChecked: isChecked)
        }
    }

    private var icon: some View {
        viewModel.icon
            .foregroundColor(.textDarkest)
    }

    private var title: some View {
        Text(viewModel.title)
            .foregroundColor(.textDarkest)
            .font(.regular17)
            .multilineTextAlignment(.leading)
    }

    private var disclosureIndicator: some View {
        InstDisclosureIndicator()
            .padding(.leading, 10)
            .hidden(!viewModel.isTappable)
    }

    private var labels: some View {
        FlowStack { leading, top in
            ForEach(viewModel.labels) {
                Text($0.text)
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    .padding(.bottom, 3)
                    .foregroundColor($0.color)
                    .font(.regular12)
                    .background(Capsule().stroke($0.color))
                    .padding(.trailing, 4)
                    .padding(.bottom, 2)
                    .padding(.top, 2)
                    .alignmentGuide(.leading, computeValue: leading)
                    .alignmentGuide(.top, computeValue: top)
            }
        }
        .padding(.bottom, 5)
        .padding(.top, 5)
    }

    private var due: some View {
        Text(viewModel.dueText)
            .font(.regular12)
            .foregroundColor(.textDark)
    }

    private func score(text: String) -> some View {
        Text(text)
            .font(.bold17)
            .foregroundColor(.textDarkest)
    }

    private func checkBox(isChecked: Bool) -> some View {
        var button = Button(action: viewModel.checkboxTapped, label: {
            // This allows the hit area to be big while keeping the icon normal sized
            let background = Color.clear
                .frame(width: 60)
                .frame(maxHeight: .infinity)

            if isChecked {
                background.overlay(Image.filterCheckbox)
            } else {
                let icon = RoundedRectangle(cornerRadius: 3).stroke(Color.textDarkest, lineWidth: 1).frame(width: 21, height: 21)
                background.overlay(icon)
            }
        })
        .accessibility(label: Text(viewModel.title) + Text(verbatim: ",") + Text("Mark item as done", bundle: .core))

        if isChecked {
            button = button.accessibility(addTraits: .isSelected)
        } else {
            button = button.accessibility(removeTraits: .isSelected)
        }

        return button
    }

    private func subtitle(model: K5ScheduleEntryViewModel.SubtitleViewModel) -> some View {
        Text(model.text)
            .foregroundColor(model.color)
            .font(model.font)
            .padding(.top, 4)
            .multilineTextAlignment(.leading)
    }
}

#if DEBUG

struct K5ScheduleEntryView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        // Add to one stack to test if different layouts have their elements horizontally aligned
        VStack(alignment: .leading) {
            ForEach(K5Preview.Data.Schedule.entries) {
                K5ScheduleEntryView(viewModel: $0)
            }
        }.previewLayout(.sizeThatFits)
    }
}

#endif
