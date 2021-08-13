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

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    var viewModel: K5GradeCellViewModel

    var gradePercentage: Double {
        guard let grade = viewModel.grade else { return viewModel.score ?? 0 }
        return Double(grade) ?? 0 / 0.05
    }

    var roundedDisplayGrade: String {
        guard let score = viewModel.score else { return viewModel.grade ?? "" }
        return "\(Int(score.rounded()))%"
    }

    init(with viewModel: K5GradeCellViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                env.router.route(to: "/courses/\(viewModel.courseID)/grades/", from: controller, options: .push)
            }, label: {
                HStack(spacing: 13) {
                    if geometry.size.width > 396 {
                        if let imageURL = viewModel.imageURL {
                            RemoteImage(imageURL, width: 72, height: 72).cornerRadius(4)
                        } else {
                            Rectangle().frame(width: 72, height: 72).cornerRadius(4).foregroundColor(viewModel.color)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.title.uppercased())
                            .font(.bold17)
                            .foregroundColor(viewModel.color)
                        HStack {
                            let percentage = gradePercentage
                            GradeProgressBar(percentage: percentage, color: viewModel.color).frame(height: 16)
                            Image.arrowOpenRightLine
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.ash)
                        }
                        if viewModel.grade == nil, viewModel.score == nil {
                            Text("Not Graded", bundle: .core).font(.regular17)
                        } else {
                            Text(roundedDisplayGrade).font(.regular17)
                        }

                    }
                }
            })
        }
        .frame(minHeight: 72).padding(.top, 13.5).padding(.bottom, 13.5)
    }
}

struct K5GradeCell_Previews: PreviewProvider {
    static var previews: some View {
        K5GradeCell(with: K5GradeCellViewModel(a11yId: "", title: "ART", imageURL: nil, grade: nil, score: 55, color: .yellow, courseID: ""))
    }
}

struct GradeProgressBar: View {
    @State var percentage: Double
    @State var color: Color
    @State private var animate: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(.clear)
                    .border(color, width: 1)
                let clampedPercentage = min(max(percentage, 0), 100)
                Rectangle().frame(width: abs(min(CGFloat(clampedPercentage) / 100.0 * geometry.size.width, geometry.size.width)),
                                  height: geometry.size.height, alignment: .leading)
                    .foregroundColor(color)
                //.animation(.spring(response: 0.55, dampingFraction: 0.55, blendDuration: 0.55))
            }.clipped()
        }
//         .onAppear {
//            animate = true
//        }.onDisappear {
//            animate = false
//        }
    }
}

struct GradeProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        GradeProgressBar(percentage: 50, color: .red).frame(height: 16)
    }
}
