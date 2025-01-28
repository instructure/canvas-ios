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
        case pages
        case success
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

    private var panda: some View {
        let scene: PandaScene

        switch selectedPanda {
        case .discussions:
            scene = DiscussionsPanda()
        case .files:
            scene = FilesPanda()
        case .grades:
            scene = GradesPanda()
        case .space:
            scene = SpacePanda()
        case .people:
            scene = PeoplePanda()
        case .modules:
            scene = ModulesPanda()
        case .quizzes:
            scene = QuizzesPanda()
        case .conferences:
            scene = ConferencesPanda()
        case .pages:
            scene = PagesPanda()
        case .success:
            scene = SuccessPanda()
        }

        return InteractivePanda(scene: scene, title: Text(verbatim: "Title Text"), subtitle: Text(verbatim: "Optional subtitle text here"))
    }
}

struct PandaGallery_Previews: PreviewProvider {
    static var previews: some View {
        PandaGallery()
    }
}
