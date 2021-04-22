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

public class RichContentEditorWrapper: UIView {
    let controller = RichContentEditorViewController()

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard controller.parent == nil else { return }
        controller.webView.addScript("addEventListener('focus', e => webkit.messageHandlers.onFocus.postMessage({}))")
        controller.webView.handle("onFocus") { [weak self] message in
            self?.onFocus(message.body as? NSDictionary ?? [:])
        }
        parentViewController?.embed(controller, in: self)
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        pin(inside: superview, top: 0.5, bottom: 0.5)
    }

    deinit {
        controller.unembed()
    }

    @objc public var context: String {
        get { controller.context.pathComponent }
        set { controller.context = Context(path: newValue) ?? .currentUser }
    }

    @objc public var html: String = "" {
        didSet {
            if oldValue != html {
                controller.setHTML(html)
            }
        }
    }
    @objc public func getHTML(_ callback: @escaping (String) -> Void) {
        controller.getHTML(callback)
    }

    @objc public var onFocus: (NSDictionary) -> Void = { _ in }

    @objc public var placeholder: String {
        get { controller.placeholder }
        set { controller.placeholder = newValue }
    }

    @objc public var a11yLabel: String {
        get { controller.a11yLabel }
        set { controller.a11yLabel = newValue }
    }

    @objc public var uploadContext: String {
        get {
            switch controller.uploadContext {
            case let .context(context):
                return "\(context.pathComponent)/files"
            case let .submission(courseID, assignmentID, _):
                return "courses/\(courseID)/assignments/\(assignmentID)/submissions/self/files"
            case let .submissionComment(courseID, assignmentID, userID):
                return "courses/\(courseID)/assignments/\(assignmentID)/submissions/\(userID)/comments/files"
            }
        }
        set {
            guard let context = Context(path: newValue) else { return }
            let components = newValue.split(separator: "/")
            if components.count == 8, components[2] == "assignments", components[4] == "submissions", components[6] == "comments" {
                controller.uploadContext = .submissionComment(courseID: context.id, assignmentID: String(components[3]), userID: String(components[5]))
            } else if components.count == 7, components[2] == "assignments", components[4] == "submissions" {
                controller.uploadContext = .submission(courseID: context.id, assignmentID: String(components[3]), comment: nil)
            } else {
                controller.uploadContext = .context(context)
            }
        }
    }
}
