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

struct NotificationCard: View {
    @ObservedObject var notification: AccountNotification

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var isExpanded = false

    var body: some View {
        HStack(spacing: 0) {
            VStack {
                icon.foregroundColor(.white)
                    .padding(.horizontal, 8).padding(.top, 10)
                    .accessibility(hidden: true)
                Spacer()
            }
                .background(backgroundColor)
                .onTapGesture { withAnimation { isExpanded.toggle() } }
            VStack(spacing: 0) {
                let button = Button(action: { withAnimation { isExpanded.toggle() } }, label: {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack { Spacer() }
                        Text(notification.subject)
                            .font(.semibold16).foregroundColor(.textDarkest).multilineTextAlignment(.leading)
                            .accessibilityIdentifier("AccountNotification.\(notification.id).title")
                        if !isExpanded {
                            Text("Tap to view announcement", bundle: .core)
                                .font(.regular14).foregroundColor(.textDark)
                                .padding(.bottom, 12)
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 12)
                })
                if isExpanded {
                    button
                        .accessibility(label: Text("Hide content for \(notification.subject)", bundle: .core))
                        .identifier("AccountNotification.\(notification.id).toggleButton")
                } else {
                    button
                        .identifier("AccountNotification.\(notification.id).toggleButton")
                }
                if isExpanded {
                    WebView(html: notification.message)
                        .onLink { url in
                            env.router.route(to: url, from: controller, options: .detail)
                            return true
                        }
                        .frameToFit()
                        .accessibility(hidden: !isExpanded)
                        .identifier("AccountNotification.\(notification.id).body")
                        .frame(maxHeight: isExpanded ? nil : 0, alignment: .top)
                        .clipped()
                        .padding(.trailing, 1)
                    HStack {
                        Spacer()
                        Button(action: {
                            DeleteAccountNotification(id: notification.id).fetch()
                        }, label: {
                            Text("Dismiss", bundle: .core)
                                .font(.semibold16).foregroundColor(Color(Brand.shared.linkColor))
                                .padding(.horizontal, 16).padding(.bottom, 12)
                        })
                        .accessibility(label: Text("Dismiss \(notification.subject)", bundle: .core))
                        .identifier("AccountNotification.\(notification.id).dismissButton")
                    }
                }
            }
        }
            .background(RoundedRectangle(cornerRadius: 4).stroke(backgroundColor))
            .background(Color.backgroundLightest)
            .cornerRadius(4)
    }

    var icon: Image {
        switch notification.icon {
        case .error, .warning:
            return .warningLine
        case .question:
            return .questionLine
        case .calendar:
            return .calendarMonthLine
        case .information:
            return .infoLine
        }
    }

    var backgroundColor: Color {
        switch notification.icon {
        case .error:
            return .backgroundDanger
        case .warning:
            return .backgroundWarning
        case .calendar, .information, .question:
            return Color(Brand.shared.primary)
        }
    }
}
