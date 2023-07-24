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
    @State private var confettiVisible = false

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
                    .animation(.default, value: viewModel.state)
                    Spacer()
                }
            }
        }
        .background(Color.backgroundLightest)
        .navBarItems(leading: barButton(viewModel.leftBarButton), trailing: barButton(viewModel.rightBarButton))
        .navigationTitle(viewModel.title)
        .onReceive(viewModel.presentDialog) {
            env.router.show($0, from: controller, options: .modal())
        }
        .onReceive(viewModel.dismiss) { completion in
            env.router.dismiss(controller, completion: completion)
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

    @ViewBuilder
    private var successView: some View {
        GeometryReader { geometry in
            InteractivePanda(scene: SuccessPanda(), title: Text("Submission Success!", bundle: .core), subtitle: Text("Your file was successfully submitted.\nEnjoy your day!", bundle: .core))
                .padding(40)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .accessibilityElement(children: .combine)

            if confettiVisible {
                LottieView(name: "confetti", loopMode: .playOnce)
                    .allowsHitTesting(false)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.confettiVisible = true
                let feedback = UIImpactFeedbackGenerator(style: .rigid)
                feedback.impactOccurred()
            }
        }
        .onDisappear {
            confettiVisible = false
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch viewModel.state {
        case .waiting:
            VStack(spacing: 15) {
                Text("Preparing Files For Upload")
                    .font(.regular14)
                    .foregroundColor(.textDarkest)
                progressView()
            }
            .padding(Typography.Spacings.textCellIconLeadingPadding)
            Divider()
        case .success:
            SwiftUI.EmptyView()
        case .uploading(let progressText, let progress):
            VStack(spacing: 15) {
                Text(progressText)
                    .font(.regular14)
                    .foregroundColor(.textDarkest)
                    .animation(.none)
                progressView(value: progress)
            }
            .padding(Typography.Spacings.textCellIconLeadingPadding)
            Divider()
        case .failed(let message, let error):
            VStack(spacing: 4) {
                Text("Submission Failed", bundle: .core)
                    .font(.bold16)
                Text(message)
                    .font(.regular14)
                    .multilineTextAlignment(.center)
                if let error = error {
                    Button(action: { showAlertDialog(message: error) }) {
                        Text("Tap here for details", bundle: .core)
                            .font(.regular14)
                            .foregroundColor(Color(Brand.shared.primary))
                    }
                }
            }
            .foregroundColor(Color.textDarkest)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .accessibilityElement(children: .combine)
            Divider()
        }
    }

    @ViewBuilder private func progressView(value: Float? = nil) -> some View {
        if let progress = value {
            ProgressView(value: progress)
                .progressViewStyle(
                    .determinateBar()
                )
        } else {
            ProgressView()
                .progressViewStyle(
                    .indeterminateBar()
                )
        }
    }

    private func showAlertDialog(message: String) {
        let dismissAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel)
        let alert = UIAlertController(title: NSLocalizedString("Error Details", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(dismissAction)
        controller.value.present(alert, animated: true)
    }
}

#if DEBUG

struct FileProgressListView_Previews: PreviewProvider {
    @ViewBuilder
    static var previews: some View {
        let staticStates: [FileProgressListViewState] = [
            .waiting,
            .uploading(progressText: "Uploading 10 MB of 13 MB", progress: 0.66),
            .failed(message: "error happened", error: "unknown error"),
            .success,
        ]

        ForEach(staticStates) {
            FileProgressListView(viewModel: FileProgressListViewPreview.PreviewViewModel(state: $0))
                .previewLayout(.fixed(width: 400, height: 600))
            FileProgressListView(viewModel: FileProgressListViewPreview.PreviewViewModel(state: $0))
                .previewLayout(.fixed(width: 400, height: 600))
                .preferredColorScheme(.dark)
        }

        VStack {
            FileProgressListView(viewModel: FileProgressListViewPreview.PreviewViewModel(state: nil))
            Spacer()
        }
        .previewLayout(.fixed(width: 400, height: 600))
        .previewDisplayName("Looping Demo")
    }
}

#endif
