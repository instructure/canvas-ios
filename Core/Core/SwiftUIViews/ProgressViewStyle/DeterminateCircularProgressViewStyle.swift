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

struct DeterminateCircularProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        let progress = configuration.fractionCompleted ?? 0
        return ZStack {
            Circle()
                .stroke(
                    Color.accentColor,
                    lineWidth: 3
                )
                .opacity(0.2)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.none, value: progress)
                .transition(.scale)
        }
        .frame(width: 32, height: 32)
    }
}

extension ProgressViewStyle where Self == DeterminateCircularProgressViewStyle {
    static var determinateCircular: DeterminateCircularProgressViewStyle { .init() }
}

struct DeterminateCircularProgressViewStyle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(value: 0.25)
            .progressViewStyle(.determinateCircular)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(.determinateCircular)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.25)
            .progressViewStyle(.determinateCircular)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)

        ProgressView(value: 0.75)
            .progressViewStyle(.determinateCircular)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
