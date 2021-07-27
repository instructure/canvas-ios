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

    @State var gradeSelectorOpen = false

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
                    Text("Grade cells go here")
                    Spacer()
                }
            }
        }
    }
}

struct K5GradesView_Previews: PreviewProvider {
    static var previews: some View {
        K5GradesView()
    }
}

struct K5GradeCell: View {

    @State var color: Color
    @State var title: String
    @State var gradeValue: Int

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 13) {
                if geometry.size.width > 396 {
                    Image.eyeSolid.frame(width: 72, height: 72).cornerRadius(4).foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.bold17)
                    GradeProgressBar(value: gradeValue, color: color).frame(height: 16)
                    Text("\(gradeValue)" + "%").font(.regular17)
                }
            }
        }.frame(minHeight: 72).padding(.top, 13.5).padding(.bottom, 13.5)
    }
}

struct K5GradeCell_Previews: PreviewProvider {
    static var previews: some View {
        K5GradeCell(color: .yellow, title: "ART", gradeValue: 50)
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
