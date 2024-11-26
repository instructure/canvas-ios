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

import SwiftUI
import Core

struct AITutorView: View {
    let viewModel: AITutorViewModel
    @Environment(\.viewController) private var viewController
    private let types = AITutorType.allCases

    var body: some View {
        VStack {
            headerView
            ZStack(alignment: .bottomTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack {
                        ForEach(types, id: \.self) { item in
                            AITutorButton(item: item) { selectedItem in
                                viewModel.didSelectTutorType.send(selectedItem)
                            }
                        }
                    }
                }
                chatBotButton
            }
        }
        .paddingStyle([.horizontal, .top], .standard)
        .applyHorizonGradient()
        .onFirstAppear { viewModel.controller = viewController }
    }

    private var chatBotButton: some View {
        Button {
            viewModel.presentChatBot()
        } label: {
            Image(systemName: "sparkles")
                .foregroundStyle(Color(red: 2/255, green: 103/255, blue: 45/255))
                .frame(width: 60, height: 60)
                .background(Color.backgroundLightest)
                .clipShape(.circle)
                .shadow(radius: 5)
        }
    }

    private var headerView: some View {
        ZStack(alignment: .trailingLastTextBaseline) {
            Text("AI Tutor")
                .foregroundStyle(Color.textLightest)
                .frame(maxWidth: .infinity)
                .font(.bold20)

            Button {
                viewModel.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.textLightest)
                    .padding()
                    .background(Color.backgroundLightest.opacity(0.2))
                    .clipShape(.circle)
            }
        }
    }
}

#if DEBUG
#Preview {
    AITutorView(viewModel: .init(router: AppEnvironment.shared.router))
}
#endif
