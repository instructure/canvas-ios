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

struct LoginUsePolicyView: View {

    @ObservedObject var viewModel: LoginUsePolicyViewModel
    @Environment(\.viewController) var controller
    @Environment(\.appEnvironment) var env

    var body: some View {
        VStack(spacing: 0) {
            Text("Either you're a new user or the Acceptable Use Policy has changed since you last agreed to it. Please agree to the Acceptable Use Policy before you continue.", bundle: .core)
                .font(.regular16).foregroundColor(.textDarkest)
                .padding(EdgeInsets(top: 24, leading: 16, bottom: 16, trailing: 16))
            Divider().padding(.zero)
            Button {
                env.router.route(to: "/accounts/self/terms_of_service", from: controller)
            } label: {
                HStack {
                    Text("Acceptable Use Policy", bundle: .core)
                        .font(.semibold16).foregroundColor(.textDarkest)
                    Spacer()
                    InstDisclosureIndicator()
                }
                .padding()
                .frame(height: 47)
                .contentShape(Rectangle())
            }
            .buttonStyle(ContextButton(contextColor: Brand.shared.primary))
            Divider().padding(.zero)
            HStack {
                Toggle(isOn: $viewModel.isAccepted) {
                    Text("I agree to the Acceptable Use Policy.", bundle: .core)
                        .font(.semibold16).foregroundColor(.textDarkest)
                        .fixedSize()
                        .lineLimit(1)
                }
                .toggleStyle(SwitchToggleStyle(tint: Color(Brand.shared.primary)))
            }
            .padding()
            .frame(height: 47)
            Divider()
            Spacer()
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        .navigationBarStyle(.color(Brand.shared.primary))
        .navigationTitle(Text("Acceptable Use Policy", bundle: .core))
        .navigationBarItems(
            leading: Button(action: {
                controller.value.dismiss(animated: true) {
                    viewModel.cancelAcceptance()
                }
            }, label: {
                Text("Cancel", bundle: .core)
                    .font(.regular16)
                    .foregroundColor(.textLightest)
            }),
            trailing: Button(action: {
                viewModel.submitAcceptance {
                    controller.value.dismiss(animated: true)
                }
            }, label: {
                Text("Submit", bundle: .core)
                    .font(.semibold16)
                    .foregroundColor(.textLightest)
                    .opacity(viewModel.isAccepted ? 1 : 0.4)
            }).disabled(!viewModel.isAccepted)
        )
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text(viewModel.errorText ?? NSLocalizedString("Something went wrong", comment: "")))
        }
    }
}

#if DEBUG

struct LoginUsePolicyView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LoginUsePolicyViewModel(cancelled: {})
        LoginUsePolicyView(viewModel: viewModel)
    }
}

#endif
