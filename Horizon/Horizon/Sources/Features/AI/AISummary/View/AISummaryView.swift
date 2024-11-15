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

struct AISummaryView: View {

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Artificial Intelligence (AI)")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                Text("Artificial Intelligence (AI) is a branch of computer science focused on creating systems capable of performing tasks that typically require human intelligence.")

                Text("AI Categories")
                    .font(.headline)
                    .padding(.top, 5)

                Text("1. Narrow AI (Weak AI): Designed for specific tasks, such as facial recognition, recommendation systems, or language translation. These systems")

                Text("2. General AI (Strong AI): A theoretical form of AI that would perform any intellectual task a human can do. This level of AI doesn't yet exist")

                Text("Techniques in AI")
                    .font(.headline)
                    .padding(.top, 5)

                Text("AI relies on several techniques, including Machine Learning (ML), Deep Learning (DL), and Natural Language Processing (NLP).")

                Text("• Machine Learning (ML): Algorithms that enable systems to learn from data and improve over time. Key ML techniques include supervised learning")

                Text("• Deep Learning (DL): A subset of ML that uses neural networks with many layers to process complex data patterns, often used in image and speech recognition.")

                Text("• Natural Language Processing (NLP): Techniques that help machines understand and generate human language, enabling applications like chatbots and language translation.")

                Text("Applications and Considerations")
                    .font(.headline)
                    .padding(.top, 5)

                Text("AI has vast applications across industries like healthcare, finance, transportation, and entertainment")
            }
            .foregroundStyle(Color.backgroundLightest)
        }
        .navigationTitle("AI Summary")
        .padding()
        .applyHorizonGradient()
    }
}

#Preview {
    AISummaryView()
}
