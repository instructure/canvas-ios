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

struct K5GradeCell: View {

    var viewModel: K5GradeCellViewModel

    init(with viewModel: K5GradeCellViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 13) {
                if geometry.size.width > 396 {
                    if let imageURL = viewModel.imageURL {
                        RemoteImage(imageURL, width: 72, height: 72).cornerRadius(4)
                    } else {
                        Rectangle().frame(width: 72, height: 72).cornerRadius(4).foregroundColor(viewModel.color)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(viewModel.title)
                        .font(.bold17)
                    GradeProgressBar(value: viewModel.grade, color: viewModel.color).frame(height: 16)
                    Text("\(viewModel.grade)" + "%").font(.regular17)
                }
            }
        }.frame(minHeight: 72).padding(.top, 13.5).padding(.bottom, 13.5)
    }
}

struct K5GradeCell_Previews: PreviewProvider {
    static var previews: some View {
        K5GradeCell(with: K5GradeCellViewModel(a11yId: "", title: "ART", imageURL: nil, grade: 55, color: .yellow))
    }
}

struct GradeProgressBar: View {
    @State var value: Int
    @State var color: Color
    @State private var animate: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(.clear)
                    .border(color, width: 1)

                Rectangle().frame(width: min(CGFloat(animate ? value : 0)/100.0*geometry.size.width, geometry.size.width),
                                  height: geometry.size.height)
                    .foregroundColor(color)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5))
            }
        }.onAppear {
            animate.toggle()
        }
    }
}

struct GradeProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        GradeProgressBar(value: 50, color: .red).frame(height: 16)
    }
}
