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

import SwiftUI
import FoundationModels

struct FoundationModelsStatusView<Content: View>: View {
    @ViewBuilder
    let availableContent: () -> Content

    var body: some View {
        if #available(iOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available: availableContent()
            case .unavailable(let reason):
                Label {
                    switch reason {
                    case .deviceNotEligible:
                        Text(verbatim: "This device does not support Apple Intelligence")
                    case .appleIntelligenceNotEnabled:
                        Text(verbatim: "Apple Intelligence is not enabled on the system")
                    case .modelNotReady:
                        Text(verbatim: "Apple Intelligence model is downloading")
                    @unknown default:
                        Text(verbatim: "Apple Intelligence is not available")
                    }
                } icon: {
                    Image(systemName: "apple.intelligence.badge.xmark")
                }
            }
        } else {
            Label {
                Text(verbatim: "Apple Intelligence requires iOS 26 or later")
            } icon: {
                Image(systemName: "apple.intelligence.badge.xmark")
            }

        }
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        FoundationModelsStatusView {
            Text("Model is available")
        }
    } else {
        Text("iOS 26 is required for this view")
    }
}
