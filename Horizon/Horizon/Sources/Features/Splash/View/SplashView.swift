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

import Core
import SwiftUI

struct SplashView: View {
    @ObservedObject private var viewModel: SplashViewModel
    @State private var rotationDegree: Double = 0

    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Image.instructureSolid
            .resizable()
            .frame(width: 64, height: 64)
            .foregroundColor(.orange)
            .rotationEffect(.degrees(rotationDegree))
            .onAppear {
                withAnimation(.linear(duration: 1).speed(0.1).repeatForever(autoreverses: false)) {
                    rotationDegree = 360
                }
            }
            .onFirstAppear {
                viewModel.viewDidAppear.send(())
            }
    }
}

#Preview {
    SplashView(
        viewModel: .init(
            interactor: .init(),
            router: AppEnvironment.shared.router
        )
    )
}
