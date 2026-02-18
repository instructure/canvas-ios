//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct FileUploadProgressCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let card: FileUploadCardState
    let onDismiss: () -> Void

    var body: some View {
        DashboardWidgetCard(backgroundColor: card.state.backgroundColor) {
            HStack(alignment: .top, spacing: 8) {
                if card.state == .success {
                    Image.publishLine
                        .scaledIcon(size: 20)
                        .accessibilityHidden(true)
                } else if card.state == .failed {
                    Image.warningLine
                        .scaledIcon(size: 20)
                        .accessibilityHidden(true)
                }

                VStack(alignment: .leading, spacing: 2) {
                    title
                    subtitle

                    if card.state == .uploading, let progress = card.progress {
                        progressBar(progress: progress)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)

                Button(action: onDismiss) {
                    Image.xLine
                        .scaledIcon(size: 24)
                }
                .accessibilityLabel(.init(localized: "Dismiss", bundle: .student))
            }
            .paddingStyle(set: .standardCell)
            .foregroundStyle(.textLightest)
        }
    }

    @ViewBuilder
    private func progressBar(progress: Float) -> some View {
        ProgressView(value: progress)
            .paddingStyle(.vertical, .textVertical)
            .padding(.trailing, 48)
            .progressViewStyle(.determinateBorderedBar(color: .textLightest))
    }

    @ViewBuilder
    private var title: some View {
        Text(card.state.title)
            .font(.semibold16, lineHeight: .fit)
    }

    @ViewBuilder
    private var subtitle: some View {
        Text(card.subtitleText)
            .font(.regular14, lineHeight: .fit)
    }
}

#if DEBUG

#Preview {
    struct AnimatedPreview: View {
        @State private var currentStateIndex = 0
        @State private var progress: Float = 0.0

        let states: [FileUploadCardState.UploadState] = [.uploading, .success, .failed]

        var body: some View {
            VStack(spacing: 24) {
                FileUploadProgressCardView(
                    card: FileUploadCardState(
                        id: "1",
                        assignmentName: "Battery Manufacturing",
                        state: states[currentStateIndex],
                        progress: states[currentStateIndex] == .uploading ? progress : nil
                    ),
                    onDismiss: {}
                )
            }
            .padding()
            .task {
                while true {
                    if states[currentStateIndex] == .uploading {
                        for i in 0...10 {
                            progress = Float(i) / 10.0
                            try? await Task.sleep(for: .milliseconds(200))
                        }
                    }

                    try? await Task.sleep(for: .seconds(1))

                    withAnimation {
                        currentStateIndex = (currentStateIndex + 1) % states.count
                        progress = 0.0
                    }

                    try? await Task.sleep(for: .seconds(1))
                }
            }
        }
    }

    return AnimatedPreview()
}

#Preview("All States") {
    VStack(spacing: 24) {
        FileUploadProgressCardView(
            card: FileUploadCardState(
                id: "1",
                assignmentName: "Battery Manufacturing",
                state: .uploading,
                progress: 0.6
            ),
            onDismiss: {}
        )

        FileUploadProgressCardView(
            card: FileUploadCardState(
                id: "2",
                assignmentName: "Math Homework",
                state: .success,
                progress: nil
            ),
            onDismiss: {}
        )

        FileUploadProgressCardView(
            card: FileUploadCardState(
                id: "3",
                assignmentName: "Essay Draft",
                state: .failed,
                progress: nil
            ),
            onDismiss: {}
        )
    }
    .padding()
}

#endif
