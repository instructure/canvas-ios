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

import Core
import SwiftUI

public struct HorizonWebSession<Content: View>: View {
    public let content: (String?) -> Content
    public let url: URL?

    @Environment(\.appEnvironment) var env

    @State var html: String?
    @State var loaded: URL?

    public init(url: URL?, @ViewBuilder content: @escaping (String?) -> Content) {
        self.content = content
        self.url = url
    }

    public var body: some View {
        if url == nil || (html != nil && url == loaded) {
            content(html)
        } else {
            VStack {
                HStack { Spacer() }
                Spacer()
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
                Spacer()
            }
                .onAppear {
                    if let url = self.url { // Ensure loaded is the url requested
                        env.api.makeRequest(GetEmbeddedWebPage(from: url)) { response, _, _ in
                            performUIUpdate {
                                loaded = url
                                html = response
                            }
                        }
                    }
                }
        }
    }
}
