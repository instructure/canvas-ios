//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

struct K5GradesView: View {

    @ObservedObject private var viewModel: K5GradesViewModel
    @State var gradeSelectorOpen = false

    init(viewModel: K5GradesViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Select").font(.regular13)
                HStack {
                    Text("Current Grading Period").font(.bold24)
                    Image.arrowOpenDownSolid.rotationEffect(.degrees(gradeSelectorOpen ? -180 : 0)).animation(.easeOut)
                    Spacer()
                }.onTapGesture {
                    gradeSelectorOpen.toggle()
                }
                if gradeSelectorOpen {
                    Text("Grading periods go here")
                }
            }.padding(.top, 15).padding(.bottom, 13)
            Divider()
            ScrollView {
                VStack {
                    ForEach(viewModel.grades) {
                        K5GradeCell(with: $0)
                        Divider()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct K5GradesView_Previews: PreviewProvider {
    static var previews: some View {
        K5GradesView(viewModel: K5GradesViewModel() )
    }
}
