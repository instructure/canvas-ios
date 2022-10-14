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

import Foundation
import SwiftUI

public struct OldInboxView: View {
    enum Scope: CaseIterable, Hashable {
        case all, unread, starred, sent, archived

        var text: String {
            switch self {
            case .all: return NSLocalizedString("All", comment: "")
            case .unread: return NSLocalizedString("Unread", comment: "")
            case .starred: return NSLocalizedString("Starred", comment: "")
            case .sent: return NSLocalizedString("Sent", comment: "")
            case .archived: return NSLocalizedString("Archived", comment: "")
            }
        }

        var apiScope: GetConversationsRequest.Scope? {
            switch self {
            case .all: return nil
            case .unread: return .unread
            case .starred: return .starred
            case .sent: return .sent
            case .archived: return .archived
            }
        }
    }

    @Environment(\.viewController) var controller
    @ObservedObject var courses: Store<GetAllCourses>
    @State @ObservedObject var conversations: Store<GetConversations>
    @State var selectedCourse: Course?

    @State var selectedScope: Scope = .all

    static func conversations(scope: Scope, course: Course?) -> Store<GetConversations> {
        AppEnvironment.shared.subscribe(GetConversations(scope: scope.apiScope, filter: course?.name)).refresh()
    }

    public init(conversations: Store<GetConversations>, courses: Store<GetAllCourses>) {
        self._selectedScope = State(initialValue: .all)
        self._conversations = State(initialValue: ObservedObject(initialValue: conversations))
        self.courses = courses
    }

    public init() {
        self.init(
            conversations: Self.conversations(scope: .all, course: nil),
            courses: AppEnvironment.shared.subscribe(GetAllCourses()).exhaust()
        )
    }

    @ViewBuilder
    func text(forScope scope: Scope) -> some View {
        Text(verbatim: scope.text)
            .frame(height: 44)
            .foregroundColor(scope == selectedScope ? .accentColor : .textDark)
            .padding(.horizontal, 16)
            .font(.semibold14)
    }

    var scopeUnderline: some View {
        HStack(spacing: 0) {
            ForEach(Scope.allCases.prefix { $0 != selectedScope }, id: \.self) { scope in
                self.text(forScope: scope).opacity(0)
            }
            text(forScope: selectedScope)
                .opacity(0)
                .background(Color.accentColor.frame(height: 3).padding(.horizontal, 8), alignment: .bottom)
                .animation(.interactiveSpring(), value: selectedScope)
        }.accessibility(hidden: true)
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .bottomLeading) {
                    scopeUnderline
                    HStack(spacing: 0) {
                        ForEach(Scope.allCases, id: \.self) { scope in
                            Button(action: {
                                guard self.selectedScope != scope else { return }
                                self.selectedScope = scope
                                self.conversations = Self.conversations(scope: scope, course: self.selectedCourse)
                            }) {
                                self.text(forScope: scope)
                            }
                        }
                    }.frame(height: 44)
                }
            }
            Divider()
            if courses.count > 0 {
                HStack(alignment: .firstTextBaseline) {
                    Text(verbatim: selectedCourse?.name ?? NSLocalizedString("All courses", comment: ""))
                        .font(.heavy24)
                        .lineLimit(1)
                    Spacer()
                    Button(action: {}) {
                        selectedCourse == nil
                            ? Text("Filter", bundle: .core)
                            : Text("Clear Filter", bundle: .core)
                    }.accessibility(
                        label: selectedCourse == nil
                            ? Text("Filter Inbox", bundle: .core)
                            : Text("Clear Filter Inbox", bundle: .core)
                    ).testID("Inbox.filterButton")
                    .font(.medium16)
                }.padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                Divider()
            }
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(self.conversations.all, id: \.id) { conversation in
                        Cell(conversation: conversation)
                    }
                }
            }
        }
    }

    struct Cell: View {
        @Environment(\.appEnvironment) var env

        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter
        }()

        static let accessibilityDateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()

        let conversation: Conversation
        var body: some View {
            let participants = conversation.participants.filter { $0.id != env.currentSession?.userID }
            let subject = conversation.subject
            let sample = participants.prefix(5).map(\.displayName)

            return Button(action: {
                print("hi")
            }) {
                ZStack(alignment: .topLeading) {
                    if conversation.workflowState == .unread {
                        Circle()
                            .frame(width: 6, height: 6)
                            .foregroundColor(.electric)
                            .padding(8)
                    }
                    HStack(alignment: .top) {
                        if participants.count > 1 {
                            Circle()
                                .strokeBorder(lineWidth: 1 / UIScreen.main.scale)
                                .foregroundColor(.borderMedium)
                                .overlay(Image.groupLine.foregroundColor(.borderDark))
                                .frame(width: 40, height: 40)
                        } else {
                            Avatar(name: participants.first?.name, url: nil)
                                .frame(width: 40, height: 40)
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                if conversation.starred {
                                    Image.starSolid.size(14).foregroundColor(.accentColor)
                                }
                                if participants.count > 6 {
                                    Text("\(sample.joined(separator: ", ")) + \(participants.count - sample.count) more", bundle: .core)
                                } else {
                                    Text(verbatim: participants.map(\.displayName).joined(separator: ", "))
                                }
                            }.font(.semibold16)
                            Text(verbatim: subject)
                                .font(.regular14)
                            Text(verbatim: conversation.lastMessage)
                                .font(.regular14)
                                .foregroundColor(.textDark)
                        }.lineLimit(1)
                        Spacer()
                        if conversation.lastMessageAt != nil {
                            Text("\(conversation.lastMessageAt!, formatter: Self.dateFormatter)", bundle: .core)
                                .foregroundColor(.textDark)
                                .font(.regular12)
                        }
                    }.padding(16)
                }.accessibilityElement(children: .ignore)
                .accessibility(label: Text(verbatim: [
                    Self.accessibilityDateFormatter.string(for: conversation.lastMessageAt),
                    subject,
                    conversation.starred ? NSLocalizedString("Starred", comment: "") : nil,
                    conversation.workflowState == .unread ? NSLocalizedString("Unread", comment: "") : nil,
                ].compactMap { $0 }.joined(separator: ", ")))
            }.buttonStyle(PlainButtonStyle())
        }
    }
}

#if DEBUG
struct OldInboxView_Previews: PreviewProvider {
    static let env = PreviewEnvironment()
    static let context = env.globalDatabase.viewContext
    static var previews: some View {
        let courses = PreviewStore(useCase: GetAllCourses(), contents: [
            APICourse.make(id: "1", term: .make(name: "Fall 2020"), is_favorite: true),
            APICourse.make(id: "2", workflow_state: .available),
            APICourse.make(id: "3", workflow_state: .completed, start_at: .distantPast, end_at: .distantPast),
            APICourse.make(id: "4", start_at: .distantFuture, end_at: .distantFuture),
        ])
        let conversations = PreviewStore(useCase: GetConversations(), contents: [
            APIConversation.make(
                id: "1",
                participants: [
                    APIConversationParticipant.make(id: "3", name: "Bob", pronouns: "Pro/Noun"),
                    APIConversationParticipant.make(id: "5", name: "Foo Bar", pronouns: "Pro/Noun"),
                ],
                starred: true
            ),
            APIConversation.make(
                id: "2",
                participants: [
                    APIConversationParticipant.make(id: "3", name: "Bob", pronouns: "Pro/Noun"),
                ]
            ),
        ])
        return OldInboxView(conversations: conversations, courses: courses)
            .previewLayout(.fixed(width: 375, height: 667))
            .accentColor(.red)
    }
}
#endif
