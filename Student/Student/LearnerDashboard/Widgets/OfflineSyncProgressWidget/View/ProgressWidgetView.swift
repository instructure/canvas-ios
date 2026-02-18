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

struct ProgressWidgetView: View {
    @State var model: ProgressWidgetViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var uiScale: CGFloat = 1

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if model.uploadState == .success {
                Image.publishLine
                    .scaledIcon(size: 20)
                    .accessibilityHidden(true)
            } else if model.uploadState == .failure {
                Image.warningLine
                    .scaledIcon(size: 20)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                switch model.uploadState {
                case .uploading:
                    title
                    subtitle
                    progress
                case .success, .failure:
                    title
                    subtitle
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)

            Button(action: model.dismiss) {
                Image.xLine
                    .scaledIcon(size: 24 * uiScale.iconScale)
            }
            .accessibilityLabel(.init(localized: "Dismiss", bundle: .student))
        }
        .paddingStyle(.horizontal, .standard)
        .paddingStyle(.top, .cellTop)
        .paddingStyle(.bottom, .cellBottom)
        .foregroundStyle(.textLightest)
        .elevation(.cardLarge, background: cardBackground)
    }

    private var cardBackground: Color {
        switch model.uploadState {
        case .uploading: .backgroundDarkest
        case .success: .backgroundSuccess
        case .failure: .backgroundDanger
        }
    }

    @ViewBuilder
    private var progress: some View {
        ProgressView(value: model.progress)
            .paddingStyle(.vertical, .textVertical)
            .padding(.trailing, 48)
            .progressViewStyle(.determinateBorderedBar(color: .textLightest))
    }

    @ViewBuilder
    private var title: some View {
        Group {
            switch model.uploadState {
            case .uploading:
                switch model.uploadType {
                case .offlineContent: Text("Syncing Offline Content", bundle: .student)
                case .submission: Text("Uploading Submission", bundle: .student)
                case .file: Text("Uploading File", bundle: .student)
                }
            case .success:
                // offline content downloadown does not have a success state
                if case .submission = model.uploadType {
                    Text("Uploading Submission", bundle: .student)
                } else if case .file = model.uploadType {
                    Text("Uploading File", bundle: .student)
                }
            case .failure:
                switch model.uploadType {
                case .offlineContent:
                    Text("Offline Content Sync Failed", bundle: .student)
                case .submission:
                    Text("Submission Upload Failed", bundle: .student)
                case .file:
                    Text("File Upload Failed", bundle: .student)
                }
            }
        }
        .font(.semibold16, lineHeight: .fit)
    }

    @ViewBuilder
    private var subtitle: some View {
        Group {
            switch model.uploadState {
            case .uploading:
                switch model.uploadType {
                case .offlineContent(let courseCount):
                    Text("\(courseCount) course is syncing", bundle: .student)
                case .submission(let assignmentName):
                    Text(assignmentName)
                case .file(let fileName):
                    Text(fileName)
                }
            case .success:
                if case .submission(let assignmentName) = model.uploadType {
                    Text(assignmentName)
                } else if case .file(let fileName) = model.uploadType {
                    Text("\(fileName) is now available", bundle: .student)
                }
            case .failure:
                switch model.uploadType {
                case .offlineContent(let courseCount):
                    Text("\(courseCount) course failed to sync.\nTry again, or come back later")
                case .submission:
                    Text("We couldn't upload your submission.\nTry again, or come back later", bundle: .student)
                case .file(let fileName):
                    Text("Couldn't upload \(fileName)\nTry again, or come back later", bundle: .student)
                }
            }
        }
        .font(.regular14, lineHeight: .fit)
    }
}

#if DEBUG
#Preview {
    ScrollView {
        ForEach(ProgressWidgetViewModel.UploadState.allCases) { state in
            VStack(spacing: 16) {
                ForEach(ProgressWidgetViewModel.UploadType.allCases) { type in
                    ProgressWidgetView(
                        model: ProgressWidgetViewModel(
                            config: .init(id: .progress, order: 1, isVisible: true),
                            uploadState: state,
                            uploadType: type,
                            progress: Float.random(in: 0...1)
                        )
                    )
                }
            }
            .padding()
            .background(.backgroundLight, in: RoundedRectangle(cornerRadius: 24))
        }
        .padding()
    }
}
#endif
