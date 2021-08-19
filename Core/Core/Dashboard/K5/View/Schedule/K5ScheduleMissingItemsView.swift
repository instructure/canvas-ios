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

public struct K5ScheduleMissingItemsView: View {
    @State private var isOpened = false
    private let missingItems: [K5ScheduleEntryViewModel]

    public init(missingItems: [K5ScheduleEntryViewModel]) {
        self.missingItems = missingItems
    }

    public var body: some View {
        VStack(spacing: 0) {
            Divider()

            Button(action: {
                withAnimation {
                    isOpened.toggle()
                }
            }, label: {
                HStack(spacing: 12) {
                    Image.warningLine
                        .foregroundColor(.crimson)
                        .padding(.leading, 18)
                    Image.arrowOpenDownLine
                        .foregroundColor(Color(Brand.shared.primary))
                        .rotationEffect(.degrees(isOpened ? -180 : 0))
                    Text(missingItemsText)
                        .font(.regular17)
                        .foregroundColor(Color(Brand.shared.primary))
                    Spacer()
                }
            })
            .frame(height: 58)
            .background(Color.white)
            .zIndex(1)

            if isOpened {
                VStack(spacing: 0) {
                    ForEach(missingItems) {
                        Divider().padding(.leading, 48)
                        K5ScheduleEntryView(viewModel: $0)
                    }
                }
                .transition(.move(edge: .top))
            }

            Divider()
        }
        .clipped()
    }

    private var missingItemsText: String {
        if isOpened {
            return NSLocalizedString("Hide 2 missing items", comment: "")
        } else {
            return NSLocalizedString("Show 2 missing items", comment: "")
        }
    }
}

#if DEBUG

struct K5ScheduleMissingItemsView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        VStack() {
            K5ScheduleMissingItemsView(missingItems: [
                K5Preview.Data.Schedule.entries[2],
                K5Preview.Data.Schedule.entries[2],
                K5Preview.Data.Schedule.entries[2],
            ])
            Spacer()
        }
    }
}
#endif
