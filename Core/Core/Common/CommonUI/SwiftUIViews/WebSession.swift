//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public struct WebSession<Content: View>: View {
    public let content: (URL?) -> Content
    public let url: URL?

    @Environment(\.appEnvironment) var env

    @State var sessionURL: URL?
    @State var loaded: URL?

    public init(url: URL?, @ViewBuilder content: @escaping (URL?) -> Content) {
        self.content = content
        self.url = url
    }

    public var body: some View {
        if url == nil || (sessionURL != nil && url == loaded) {
            content(sessionURL)
        } else {
            VStack {
                HStack { Spacer() }
                Spacer()
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
                Spacer()
            }
                .onAppear {
                    let url = self.url // Ensure loaded is the url requested
                    env.api.makeRequest(GetWebSessionRequest(to: url)) { response, _, _ in
                        performUIUpdate {
                            loaded = url
                            sessionURL = response?.session_url ?? url
                        }
                    }
                }
        }
    }
}
