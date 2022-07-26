//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

struct FileProgressListView<ViewModel>: View where ViewModel: FileProgressListViewModelProtocol {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            if case .success = viewModel.state {
                successView
            } else {
                VStack(spacing: 0) {
                    statusBanner
                    ForEach(viewModel.items) {
                        FileProgressItemView(viewModel: $0)
                        Divider()
                    }
                    Spacer()
                }
            }
        }
        .animation(.default)
        .navBarItems(leading: barButton(viewModel.leftBarButton), trailing: barButton(viewModel.rightBarButton))
        .navigationTitle(viewModel.title)
        .onAppear {
            viewModel.setupViewEnvironment(env: env, controller: controller)
        }
        .onReceive(viewModel.presentDialog) {
            env.router.show($0, from: controller, options: .modal())
        }
    }

    @ViewBuilder
    private func barButton(_ model: BarButtonItemViewModel?) -> some View {
        if let model = model {
            Button(action: model.action) {
                Text(model.title)
                    .foregroundColor(Color(Brand.shared.primary))
                    .font(.regular17)
            }
        } else {
            SwiftUI.EmptyView()
        }
    }

    private var successView: some View {
        VStack(spacing: 0) {
            Spacer()
            InteractivePanda(scene: ConferencesPanda(), title: Text("Submission Success!", bundle: .core), subtitle: Text("Your file was successfully submitted. Enjoy your day!", bundle: .core))
            .padding(.bottom, 21)
            Spacer()
        }
        .padding(40)
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch viewModel.state {
        case .waiting, .success:
            SwiftUI.EmptyView()
        case .uploading(let progressText, let progress):
            VStack(spacing: 15) {
                Text(progressText)
                    .font(.regular14)
                    .foregroundColor(.textDarkest)
                ProgressView(value: progress)
                    .foregroundColor(Color(Brand.shared.primary))
            }
            .padding(Typography.Spacings.textCellIconLeadingPadding)
            Divider()
        case .failed:
            VStack(spacing: 4) {
                Text("Submission Failed", bundle: .core)
                    .font(.bold16)
                Text("One or more files failed to upload. Check your internet connection and retry to submit.")
                    .font(.regular14)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.licorice)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            Divider()
        }
    }
}

#if DEBUG

struct FileProgressListView_Previews: PreviewProvider {
    @ViewBuilder
    static var previews: some View {
        let staticStates: [FileProgressListViewState] = [
            .waiting,
            .uploading(progressText: "Uploading 10 MB of 13 MB", progress: 0.66),
            .failed,
            .success,
        ]

        ForEach(staticStates) {
            FileProgressListView(viewModel: FileProgressListViewPreview.PreviewViewModel(state: $0))
                .previewLayout(.sizeThatFits)
        }

        VStack {
            FileProgressListView(viewModel: FileProgressListViewPreview.PreviewViewModel(state: nil))
            Spacer()
        }
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Looping Demo")
    }
}

#endif
