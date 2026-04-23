//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct NutritionFactModel: Identifiable {
    let id = UUID()
    let sectionName: String
    let items: [RowModel]

    struct RowModel: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let description: String
    }

  static func getSections() -> [NutritionFactModel] {
        let firstSection: NutritionFactModel = .init(
            sectionName: String(localized: "Model & Data"),
            items: [
                .init(
                    title: String(localized: "Base Model"),
                    subtitle: String(localized: "The foundational AI on which further training and customizations are built."),
                    description: String(localized: "Claude 3.5 Haiku by Anthropic and Cohere multi-language v3")
                ),
                .init(
                    title: String(localized: "Trained with User Data"),
                    subtitle: String(localized: "Indicates the AI model has been given customer data in order to improve its results."),
                    description: String(localized: "No")
                ),
                .init(
                    title: String(localized: "Data Shared with Model"),
                    subtitle: String(localized: "Indicates which training or operational content was given to the model."),
                    description: String(localized: "Course content")
                )
            ]
        )

        let secondSection: NutritionFactModel = .init(
            sectionName: String(localized: "Privacy & Compliance"),
            items: [
                .init(
                    title: String(localized: "Data Retention"),
                    subtitle: String(localized: "How long the model stores customer data."),
                    description: String(localized: "No")
                ),
                .init(
                    title: String(localized: "Data Logging"),
                    subtitle: String(localized: "Recording the AI's performance for auditing, analysis, and improvement."),
                    description: String(localized: "Chat logs are retained for 30 days for troubleshooting and debugging")
                ),
                .init(
                    title: String(localized: "Regions Supported"),
                    subtitle: String(localized: "The locations where the AI model is officially available and supported."),
                    description: String(localized: "Global")
                ),
                .init(
                    title: String(localized: "PII"),
                    subtitle: String(localized: "Sensitive data that can be used to identify an individual."),
                    description: String(localized: "Not Exposed")
                )
            ]
        )

        let thirdSection: NutritionFactModel = .init(
            sectionName: String(localized: "Outputs"),
            items: [
                .init(
                    title: String(localized: "AI Settings Control"),
                    subtitle: String(localized: "The ability to turn the AI on or off within the product."),
                    description: String(localized: "No")
                ),
                .init(
                    title: String(localized: "Human in the Loop"),
                    subtitle: String(localized: "Indicates if a human is involved in the AI's process or output."),
                    description: String(localized: "Yes")
                ),
                .init(
                    title: String(localized: "Guardrails"),
                    subtitle: String(localized: "Preventative safety mechanisms or limitations built into the AI model."),
                    description: String(localized: "Yes")
                ),
                .init(
                    title: String(localized: "Expected Risks"),
                    subtitle: String(localized: "Any risks the model may pose to the user."),
                    description: String(localized: "Low risk")
                ),
                .init(
                    title: String(localized: "Intended Outcomes"),
                    subtitle: String(localized: "The specific results the AI model is meant to achieve."),
                    description: String(localized: "AI Generated content may contain mistakes or inaccurate information and should always be verified")
                )

            ]
        )
        return [firstSection, secondSection, thirdSection]
    }
}
