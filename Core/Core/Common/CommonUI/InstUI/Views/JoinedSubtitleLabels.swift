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

import SwiftUI

extension InstUI {

    public struct JoinedSubtitleLabels<Label1: View, Label2: View>: View {

        private let label1: () -> Label1
        private let label2: () -> Label2

        private let alignment: VerticalAlignment
        private let spacing: CGFloat
        private let dividerVerticalPadding: CGFloat

        public init(
            label1: @escaping () -> Label1,
            label2: @escaping () -> Label2,
            alignment: VerticalAlignment = .center,
            spacing: CGFloat = 4,
            dividerVerticalPadding: CGFloat = 2
        ) {
            self.label1 = label1
            self.label2 = label2
            self.alignment = alignment
            self.spacing = spacing
            self.dividerVerticalPadding = dividerVerticalPadding
        }

        public var body: some View {
            HStack(alignment: alignment, spacing: spacing) {
                label1()
                InstUI.SubtitleTextDivider()
                    .padding(.vertical, dividerVerticalPadding)
                label2()
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    public struct SubtitleTextDivider: View {
        public init() { }

        public var body: some View {
            Color.borderMedium
                .frame(width: 1)
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
    }
}

#if DEBUG

#Preview {
    PreviewContainer {
        InstUI.Divider()

        InstUI.JoinedSubtitleLabels(
            label1: {
                Text("42 / 100 pts (C-)")
                    .textStyle(.cellLabelSubtitle)
            },
            label2: {
                SubmissionStatusLabel(model: .init(status: .graded))
            }
        )
        .padding()
        InstUI.Divider()

        InstUI.JoinedSubtitleLabels(
            label1: {
                SubmissionStatusLabel(model: .init(status: .notSubmitted))
            },
            label2: {
                Text(Date.now.dateTimeString)
                    .textStyle(.cellLabelSubtitle)
            }
        )
        .padding()
        InstUI.Divider()

        InstUI.JoinedSubtitleLabels(
            label1: {
                SubmissionStatusLabel(model: .init(text: .loremIpsumMedium, icon: .flagLine, color: .textInfo))
            },
            label2: {
                Text("Using center alignment " + .loremIpsumShort)
                    .textStyle(.cellLabelSubtitle)
            }
        )
        .padding()
        InstUI.Divider()

        InstUI.JoinedSubtitleLabels(
            label1: {
                SubmissionStatusLabel(model: .init(text: .loremIpsumMedium, icon: .flagLine, color: .textInfo))
            },
            label2: {
                Text("Using top alignment...... " + .loremIpsumShort)
                    .textStyle(.cellLabelSubtitle)
            },
            alignment: .top
        )
        .padding()
        InstUI.Divider()
    }
}

#endif
