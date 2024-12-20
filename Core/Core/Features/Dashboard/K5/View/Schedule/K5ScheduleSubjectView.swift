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

public struct K5ScheduleSubjectView: View {
    private let viewModel: K5ScheduleSubjectViewModel
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var viewController
    @Environment(\.containerSize) private var containerSize
    private var isCompact: Bool { containerSize.width < 500 }

    public init(viewModel: K5ScheduleSubjectViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
        .padding(.horizontal, 2)
        .background(RoundedRectangle(cornerRadius: 6).stroke(viewModel.subject.color, lineWidth: 4))
        .cornerRadius(3)
    }

    @ViewBuilder
    private var content: some View {
        if isCompact {
            smallView
        } else {
            largeView
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var smallView: some View {
        VStack(spacing: 0) {
            Button(action: {
                viewModel.viewTapped(router: env.router, viewController: viewController)
            }, label: {
                HStack(spacing: 0) {
                    subjectName
                        .font(.bold17)
                        .padding(.top, 5)
                        .frame(minHeight: 50)
                    Spacer()

                    if viewModel.isTappable {
                        InstDisclosureIndicator().padding(.leading, 10)
                    }
                }
                .padding(.leading, 18)
                .padding(.trailing, 15)
            })
            .accessibility(hint: Text("Open course details", bundle: .core))
            .disabled(!viewModel.isTappable)
            Divider()
            entries
        }
        // This makes button inside button work if contained in a list
        .buttonStyle(BorderlessButtonStyle())
    }

    private var largeView: some View {
        HStack(spacing: 0) {
            Button(action: {
                viewModel.viewTapped(router: env.router, viewController: viewController)
            }, label: {
                VStack(spacing: 0) {
                    subjectName
                        .font(.bold13)
                        .padding(.top, 3)
                        .frame(minHeight: 25)
                    ZStack {
                        if let image = viewModel.subject.image {
                            GeometryReader { geometry in
                                RemoteImage(image, width: geometry.size.width, height: geometry.size.height)
                                    .aspectRatio(contentMode: .fit)
                                    .clipped()
                                    // Fix big course image consuming tap events.
                                    .contentShape(Path(CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height)))
                            }
                        }
                        viewModel.subject.color.opacity(viewModel.subject.image == nil ? 1 : 0.75)
                    }
                }
                .padding(.vertical, 2)
                .frame(width: 147)
                .clipped()
            })
            .accessibility(hint: Text("Open course details", bundle: .core))
            .disabled(!viewModel.isTappable)
            verticalSeparator
            entries
                .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private var subjectName: some View {
        Text(viewModel.subject.name)
            .foregroundColor(viewModel.subject.color)
            .multilineTextAlignment(.leading)
            .textCase(.uppercase)
    }

    private var verticalSeparator: some View {
        viewModel.subject.color
            .frame(width: 2)
    }

    private var entries: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModel.entries) {
                K5ScheduleEntryView(viewModel: $0)

                if viewModel.entries.last !== $0 {
                    Divider()
                }
            }
        }
    }
}

#if DEBUG

struct K5ScheduleSubjectView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        VStack {
            ForEach(K5Preview.Data.Schedule.subjects) {
                K5ScheduleSubjectView(viewModel: $0)
            }
        }
        .previewDevice(PreviewDevice(stringLiteral: "iPad (9th generation)"))
        .environment(\.containerSize, CGSize(width: 500, height: 0))

        VStack {
            ForEach(K5Preview.Data.Schedule.subjects) {
                K5ScheduleSubjectView(viewModel: $0)
            }
        }
        .previewLayout(.device)
    }
}

#endif
