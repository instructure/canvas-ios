//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import HorizonUI
import SwiftUI

struct MessagesView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Top Navigation Bar
                HStack {
                    HorizonBackButton { _ in }
                    Spacer()
                    HorizonUI.PrimaryButton(
                        String(localized: "Create message", bundle: .horizon),
                        type: .institution,
                        leading: HorizonUI.icons.editSquare
                    ) { }
                }
                .padding(.horizontal)

                // Filters
                VStack {
                    Picker("All Messages", selection: .constant(1)) {
                        Text("All Messages").tag(1)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)

                    Picker("Filter by person", selection: .constant(1)) {
                        Text("Filter by person").tag(1)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }

                // Message List
                List {
                    MessageRow(date: "Feb 28, 2022", subject: "[ Subject ]", names: "Sharon Peck")
                    MessageRow(date: "Feb 28, 2022", subject: "[ Subject ]", names: "Jeffrey Johnson, Jeanne-Marie Beaubier")
                    MessageRow(date: "Feb 28, 2022", subject: "[ Subject ]", names: "Jeffrey Johnson, Jeanne-Marie Beaubier")
                }

                Spacer()

                // Bottom Navigation Bar
                HStack {
                    Spacer()
                    Image(systemName: "house")
                    Spacer()
                    Image(systemName: "book")
                    Spacer()
                    Image(systemName: "sparkles")
                    Spacer()
                    Image(systemName: "person.circle")
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct MessageRow: View {
    var date: String
    var subject: String
    var names: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(date)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(subject)
                .font(.headline)
            Text(names)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MessagesView()
}
