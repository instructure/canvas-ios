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

import Foundation

struct FlashCardModel: Identifiable, Hashable {
    let id: Int
    let frontContent: String
    let backContent: String
    var isFlipped = false

    var currentContent: String {
        isFlipped ? backContent : frontContent
    }

    var title: String {
        isFlipped ? String(localized: "Answer", bundle: .horizon) : String(localized: "Question", bundle: .horizon)
    }

    mutating func makeItFlipped() {
        isFlipped.toggle()
    }
}

extension FlashCardModel {
    static var mock: [FlashCardModel] {
        [
            FlashCardModel(
                id: 1,
                frontContent: """
            What is the capital of France?
            Describe its cultural significance, and mention one famous landmark that attracts millions of tourists.
            How has this city influenced world fashion and cuisine, and why is it known as the 'City of Light'?
            """,
                backContent: "Paris, known for the Eiffel Tower, fashion, and rich culture."
            ),
            FlashCardModel(
                id: 2,
                frontContent: """
            What is 2 + 2?
            Show your calculation and
            explain why this equation is fundamental in basic arithmetic. How would you apply this concept in real life, such as budgeting or counting objects?
            """,
                backContent: "4, calculated by adding 2 to 2, foundational in arithmetic."
            ),
            FlashCardModel(
                id: 3,
                frontContent: """
            What is the largest planet
            in our Solar System?
            Describe its main features, including its size, number of moons, and notable atmospheric phenomena such as the Great Red Spot. Why is this planet significant?
            """,
                backContent: "Jupiter, the largest planet with a Great Red Spot and many moons."
            ),
            FlashCardModel(
                id: 4,
                frontContent: """
            What is the chemical symbol for water? 
            Explain its molecular composition and discussthe role of water in supporting life on Earth. Mention its use in daily human activities, and its importance in ecosystems.
            """,
                backContent: "H2O, consisting of two hydrogen atoms and one oxygen atom, vital for life."
            ),
            FlashCardModel(
                id: 5,
                frontContent: """
            Who wrote 'Romeo and Juliet'?
            Name another famous work by this author and describe the impact of his writings on English literature. Discuss
            his influence on storytelling, language, and modern plays.
            """,
                backContent: "William Shakespeare, who also wrote 'Hamlet' and influenced drama."
            ),
            FlashCardModel(
                id: 6,
                frontContent: """
            What is the square root of 64?
            Explain how you determined the answer, and why knowing square roots is important. Provide examples of where
            square roots are used in fields like engineering or physics.
            """,
                backContent: "8, as it is the number which, when squared, gives 64."
            ),
            FlashCardModel(
                id: 7,
                frontContent: """
            In which year did the Titanic sink?
            Provide details about the journey it was on, the iceberg collision, and the reasons why it remains a significant
            historical event. How did this tragedy influence maritime laws?
            """,
                backContent: "1912, after hitting an iceberg, led to changes in maritime safety."
            ),
            FlashCardModel(
                id: 8,
                frontContent: """
            Who painted the Mona Lisa?
            Where is the painting currently displayed, and why is it considered an iconic work?
            Describe its historical background, artistic techniques, and reasons for its global popularity.
            """,
                backContent: "Leonardo da Vinci painted the Mona Lisa, displayed in the Louvre."
            ),
            FlashCardModel(
                id: 9,
                frontContent: """
            What is the speed of light?
            State its value in kilometers per second, and explain its role in physics. How is the speed of light used in
            space exploration, and why is it important in understanding the universe?
            """,
                backContent: "Approximately 299,792 km/s, crucial for physics and space exploration."
            ),
            FlashCardModel(
                id: 10,
                frontContent: """
            What language is primarily spoken in Brazil?
            Provide information about its origins and mention other languages spoken by communities there. How does Portuguese influence
            Brazilian culture, and why is it unique compared to Portugal's version?
            """,
                backContent: "Portuguese, influenced by indigenous languages and distinct from European Portuguese."
            )
        ]
    }
}
