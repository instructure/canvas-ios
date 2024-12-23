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

public struct PlannerScreen: View {

    @Environment(\.viewController) private var viewController

    @ObservedObject var viewModel: PlannerViewModel

    public init(viewModel: PlannerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {

            Section {

                switch viewModel.state {
                case .data:

                    if viewModel.dayPlannables.isEmpty {
                        emptyView
                    } else {
                        ForEach(viewModel.dayPlannables, id: \.id) { item in
                            PlannerListRowView(item: item)
                                .onTapGesture {
                                    viewModel.showPlannableDetails.send((item, viewController))
                                }
                        }
                    }

                case .empty:
                    emptyView

                case .error:
                    VStack {
                        Spacer()
                        InteractivePanda(config: .error()).fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(.vertical)

                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(.indeterminateCircle(size: 32))
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                        Spacer()
                    }
                    .padding(.vertical)
                }
            }
            .listSectionSeparator(.hidden)
        }
        .listStyle(.plain)
        .safeAreaInset(edge: .top) {
            CalendarView(
                selectedDay: $viewModel.selectedDay,
                calendarsTapped: {
                    viewModel.showCalendars.send(viewController)
                }
            )
            .environment(\.plannerViewModel, viewModel.wrapped())
        }
        .toolbar(content: { toolbarContent })
    }

    private var emptyView: some View {
        EmptyPanda(
            .NoEvents,
            title: Text("No Events Today!", bundle: .core),
            message: Text("It looks like a great day to rest, relax, and recharge.", bundle: .core)
        )
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showProfile.send(viewController)
            } label: {
                Image
                    .hamburgerSolid
                    .foregroundColor(Color(Brand.shared.navTextColor))
            }
        }

        ToolbarItemGroup(placement: .topBarTrailing) {

            todayButton

            Menu {

                Button {
                    viewModel.showTodoForm.send(viewController)
                } label: {
                    Label {
                        Text("Add To Do", bundle: .core)
                    } icon: {
                        Image.noteLine
                    }
                }

                Button {
                    viewModel.showEventForm.send(viewController)
                } label: {
                    Label {
                        Text("Add Event", bundle: .core)
                    } icon: {
                        Image.calendarMonthLine
                    }
                }

            } label: {
                Image
                    .addSolid
                    .foregroundColor(Color(Brand.shared.navTextColor))
            }
        }
    }

    var todayButton: some View {
        Button {
            withAnimation {
                viewModel.selectedDay = CalendarDay(
                    calendar: Cal.currentCalendar,
                    date: Clock.now
                )
            }
        } label: {
            Image
                .dayIcon(for: Clock.now)
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
    }

}

#Preview {
    NavigationView {
        PlannerScreen(
            viewModel: PlannerViewModel(date: Clock.now, router: AppEnvironment.shared.router)
        )
    }
}

extension Image {

    static func dayIcon(for date: Date) -> Image {
        let text = date.dayString
        let size = CGSize(width: 24, height: 24)
        let font: UIFont = .applicationFont(ofSize: 10, weight: .regular)
        let textY: CGFloat = 8

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraphStyle
            ]

            let attributedString = NSAttributedString(string: text, attributes: attributes)
            attributedString.draw(
                with: CGRect(x: 0, y: textY, width: size.width, height: size.height),
                options: .usesLineFragmentOrigin,
                context: nil
            )

            let bgImage = UIImage.calendarEmptyLine.withRenderingMode(.alwaysTemplate)
            bgImage.draw(at: .zero)
        }

        return Image(uiImage: image.withRenderingMode(.alwaysTemplate))
    }
}
