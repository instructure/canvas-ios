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

public class ConversationsViewController: HorizontalMenuViewController {

    var list: ConversationListViewController!
    public var viewControllers: [UIViewController] = []

    enum MenuItem: Int, CaseIterable {
        case all, unread, starred, sent, archived

        func scope() -> GetConversationsRequest.Scope? {
            switch self {
            case .all: return nil
            case .unread: return .unread
            case .starred: return .starred
            case .sent: return .sent
            case .archived: return .archived
            }
        }
    }

    public static func create() -> ConversationsViewController {
        ConversationsViewController()
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        isMultiPage = false
        delegate = self

        list = ConversationListViewController.create()
        viewControllers.append(list)

        layoutViewControllers()
        pages?.isScrollEnabled = false
    }
}

extension ConversationsViewController: HorizontalPagedMenuDelegate {
    public func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .all: identifier = "all"
        case .unread: identifier = "unread"
        case .sent: identifier = "sent"
        case .starred:  identifier = "starred"
        case .archived: identifier = "archived"
        }
        return "Conversations.\(identifier)MenuItem"
    }

    public var menuItemSelectedColor: UIColor? {
        return Brand.shared.primary
    }

    public var menuItemFont: UIFont { .scaledNamedFont(.semibold14) }

    public var numberOfMenuItems: Int { MenuItem.allCases.count }

    public func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .all:
            return NSLocalizedString("All", comment: "")
        case .unread:
            return NSLocalizedString("Unread", comment: "")
        case .sent:
            return NSLocalizedString("Sent", comment: "")
        case .starred:
            return NSLocalizedString("Starred", comment: "")
        case .archived:
            return NSLocalizedString("Archived", comment: "")
        }
    }

    public func didSelectMenuItem(at: IndexPath) {
        guard let menuItem = MenuItem(rawValue: at.row) else { return }
        list.scope = menuItem.scope()
    }
}
