//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

struct DashboardOfflineSyncProgressCardView: View {
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: DashboardOfflineSyncProgressCardViewModel

    public init(viewModel: DashboardOfflineSyncProgressCardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            switch viewModel.state {
            case .error:
                containerCard(backgroundColor: Color.textDanger) {
                    errorView
                }
            case let .progress(progress, progressText):
                containerCard(backgroundColor: Color.backgroundDarkest) {
                    progressView(progress, progressText)
                }
            case .hidden:
                SwiftUI.EmptyView()
            }
        }
        .animation(.default, value: viewModel.state)
    }

    private func containerCard(backgroundColor: Color, innerView: () -> some View) -> some View {
        Button {
            viewModel.cardDidTap.accept(viewController)
        } label: {
            innerView()
                .frame(maxWidth: .infinity)
                .foregroundColor(.textLightest)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 20)
        }
        .background(backgroundColor)
        .cornerRadius(6)
        .overlay(alignment: .topTrailing) {
            Button {
                viewModel.dismissDidTap.accept()
            } label: {
                closeIcon
                    .padding(.top, 15)
                    .padding(.trailing, 11)
                    .padding(.leading, 5)
                    .padding(.bottom, 5)
            }
            .accessibilityHidden(true)
        }
        .padding(.top, 16) // This is to add spacing between the dashboard's nav bar and this card
        .accessibilityAction(named: Text("Show sync details", bundle: .core)) {
            viewModel.cardDidTap.accept(viewController)
        }
        .accessibilityAction(named: Text("Dismiss", bundle: .core)) {
            viewModel.dismissDidTap.accept()
        }
    }

    private func progressView(_ progress: Float, _ progressText: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Syncing Offline Content", bundle: .core)
                .font(.semibold16, lineHeight: .fit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            Text(progressText)
                .font(.regular14, lineHeight: .fit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 14)
            progressBar(progress: progress)
        }
    }

    private var errorView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Offline Content Sync Failed", bundle: .core)
                .font(.semibold16, lineHeight: .fit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
            Text("One or more items failed to sync. Please check your internet connection and retry syncing.", bundle: .core)
                .font(.regular14, lineHeight: .fit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
    }

    private func progressBar(progress: Float) -> some View {
        ProgressView(value: progress)
            .progressViewStyle(
                .determinateBar(color: .textLightest)
            )
            .animation(.default, value: progress)
    }

    private var closeIcon: some View {
        Image.xLine
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundColor(.textLightest)
    }
}

#if DEBUG

struct OfflineSyncProgressCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            DashboardOfflineSyncProgressCardAssembly.makePreview()
            Spacer()
        }
        .onAppear {
            NotificationCenter.default.post(name: .OfflineSyncTriggered,
                                            object: nil)
        }
    }
}

#endif
