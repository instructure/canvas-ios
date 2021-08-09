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

public struct K5ScheduleSubjectView: View {
    private let viewModel: K5ScheduleSubjectViewModel
    @Environment(\.containerSize) private var containerSize
    private var isCompact: Bool { containerSize.width < 500 }

    public init(viewModel: K5ScheduleSubjectViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
        .padding(.horizontal, 2)
        .background(RoundedRectangle(cornerRadius: 6).stroke(viewModel.subject.color, lineWidth: 4))
        .cornerRadius(3)
    }

    @ViewBuilder
    private var content: some View {
        if isCompact {
            smallView
        } else {
            largeView
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var smallView: some View {
        VStack(spacing: 0) {
            Button(action: viewModel.viewTapped, label: {
                HStack(spacing: 0) {
                    subjectName
                        .font(.bold17)
                        .frame(minHeight: 50)
                    Spacer()

                    if viewModel.hasTapAction {
                        disclosureIndicator
                    }
                }
                .padding(.leading, 18)
                .padding(.trailing, 15)
            })
            .disabled(!viewModel.hasTapAction)
            Divider()
            entries
        }
        // This makes button inside button work if contained in a list
        .buttonStyle(BorderlessButtonStyle())
    }

    private var largeView: some View {
        HStack(spacing: 0) {
            Button(action: viewModel.viewTapped, label: {
                VStack(spacing: 0) {
                    subjectName
                        .font(.bold13)
                        .frame(minHeight: 25)
                    ZStack {
                        if let image = viewModel.subject.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        viewModel.subject.color.opacity(0.75)
                    }
                }
                .padding(.vertical, 2)
                .frame(width: 147)
                .clipped()
            })
            .disabled(!viewModel.hasTapAction)
            verticalSeparator
            entries
                .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var subjectName: some View {
        let text = Text(viewModel.subject.name).foregroundColor(viewModel.subject.color)

        if #available(iOS 14, *) {
            text.textCase(.uppercase)
        } else {
            text
        }
    }

    private var disclosureIndicator: some View {
        Image.arrowOpenRightSolid
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundColor(.ash)
            .padding(.leading, 10)
    }

    private var verticalSeparator: some View {
        viewModel.subject.color
            .frame(width: 2)
    }

    private var entries: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.entries) {
                K5ScheduleEntryView(viewModel: $0)

                if viewModel.entries.last !== $0 {
                    Divider()
                }
            }
        }
    }
}

#if DEBUG

struct K5ScheduleSubjectView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        VStack {
            ForEach(K5Preview.Data.Schedule.subjects) {
                K5ScheduleSubjectView(viewModel: $0)
            }
        }
        .previewDevice(PreviewDevice(stringLiteral: "iPad (8th generation)"))
        .environment(\.containerSize, CGSize(width: 500, height: 0))

        VStack {
            ForEach(K5Preview.Data.Schedule.subjects) {
                K5ScheduleSubjectView(viewModel: $0)
            }
        }
            .previewLayout(.device)
    }
}

#endif
