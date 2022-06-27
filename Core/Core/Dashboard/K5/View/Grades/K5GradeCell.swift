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

    init(with viewModel: K5GradeCellViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                env.router.route(to: viewModel.route, from: controller, options: .push)
            }, label: {
                HStack(spacing: 13) {
                    if geometry.size.width > 396 {
                        ZStack {
                            if let imageURL = viewModel.imageURL {
                                RemoteImage(imageURL, width: 72, height: 72).cornerRadius(4)
                            }
                            Rectangle()
                                .frame(width: 72, height: 72)
                                .cornerRadius(4)
                                .foregroundColor(viewModel.color)
                                .opacity(0.75)
                        }
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(viewModel.title.uppercased())
                            .font(.bold17)
                            .foregroundColor(viewModel.color)
                        HStack {
                            let percentage = viewModel.gradePercentage
                            K5GradeProgressBar(percentage: percentage, color: viewModel.color).frame(height: 16)
                            Image.arrowOpenRightLine
                                .resizable()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.textDark)
                        }
                        if viewModel.grade == nil, viewModel.score == nil {
                            Text("Not Graded", bundle: .core).font(.regular17)
                        } else {
                            Text(viewModel.roundedDisplayGrade).font(.regular17)
                        }
                    }
                }
            })
        }
        .frame(minHeight: 72).padding(.vertical, 13.5)
    }
}

#if DEBUG

struct K5GradeCell_Previews: PreviewProvider {
    static var previews: some View {
        K5GradeCell(with: K5GradeCellViewModel(title: "ART",
                                               imageURL: URL(string: "https://inst.prod.acquia-sites.com/sites/default/files/image/2021-01/Instructure%20Office.jpg")!,
                                               grade: nil,
                                               score: 55,
                                               color: .yellow,
                                               courseID: ""))
        K5GradeCell(with: K5GradeCellViewModel(title: "ART",
                                               imageURL: nil,
                                               grade: nil,
                                               score: 55,
                                               color: .yellow,
                                               courseID: ""))
    }
}

#endif
