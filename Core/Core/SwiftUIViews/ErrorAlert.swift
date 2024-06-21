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

import Combine
import SwiftUI

public struct ErrorAlertViewModel {
    public let title: String
    public let message: String
    public let buttonTitle: String

    public init(
        title: String,
        message: String,
        buttonTitle: String
    ) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
    }
}

public extension View {
    func errorAlert(
        isPresented: Binding<Bool>,
        presenting viewModel: ErrorAlertViewModel,
        buttonAction: @escaping () -> Void
    ) -> some View {
        alert(
            viewModel.title,
            isPresented: isPresented,
            actions: {
                Button(viewModel.buttonTitle, action: buttonAction)
            },
            message: {
                Text(viewModel.message)
            }
        )
    }
}

#if DEBUG

struct ErrorAlertPreview: PreviewProvider {

    final class DemoViewModel: ObservableObject {
            @Published var statusText = ""
            @Published var isShowingAlert = false
            let alert = ErrorAlertViewModel(
                title: "Some error happened",
                message: "You can try again.",
                buttonTitle: "Okay"
            )

            func showDidTap() {
                statusText = ""
                isShowingAlert = true
            }
        }

        struct DemoView: View {
            @StateObject var viewModel = DemoViewModel()

            var body: some View {
                ZStack {
                    VStack {
                        Spacer()
                        Text(viewModel.statusText).frame(height: 20)
                        Spacer()
                        Button {
                            viewModel.showDidTap()
                        } label: {
                            Text("Show dialog")
                        }
                        .errorAlert(isPresented: $viewModel.isShowingAlert, presenting: viewModel.alert) {
                            viewModel.statusText = "OK tapped"
                        }
                        Spacer()
                    }
                }
            }
        }

    static var previews: some View {
        DemoView()
    }
}

#endif
