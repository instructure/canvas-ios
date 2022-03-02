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

public struct PandaGallery: View {
    private enum PandaType: String, CaseIterable, Identifiable {
        var id: Self { self }

        case discussions
        case files
        case grades
        case space
        case people
        case modules
        case quizzes
        case conferences
    }
    @State private var selectedPanda: PandaType = PandaType.allCases.last!

    public init() {
    }

    public var body: some View {
        VStack {
            Spacer()
            panda
            Spacer()
            Picker("", selection: $selectedPanda) {
                ForEach(PandaType.allCases) { panda in
                    Text(panda.rawValue.capitalized)
                }
            }
                .padding()
        }
    }

    @ViewBuilder
    private var panda: some View {
        switch selectedPanda {
        case .discussions:
            InteractivePanda(scene: DiscussionsPanda())
        case .files:
            InteractivePanda(scene: FilesPanda())
        case .grades:
            InteractivePanda(scene: GradesPanda())
        case .space:
            InteractivePanda(scene: SpacePanda())
        case .people:
            InteractivePanda(scene: PeoplePanda())
        case .modules:
            InteractivePanda(scene: ModulesPanda())
        case .quizzes:
            InteractivePanda(scene: QuizzesPanda())
        case .conferences:
            InteractivePanda(scene: ConferencesPanda())
        }
    }
}

struct PandaGallery_Previews: PreviewProvider {
    static var previews: some View {
        PandaGallery()
    }
}
