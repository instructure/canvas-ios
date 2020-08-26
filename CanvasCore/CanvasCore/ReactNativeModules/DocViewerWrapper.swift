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

public class DocViewerWrapper: UIView {
    @objc public var controller: DocViewerViewController?

    @objc public var contentInset: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != contentInset else { return }
            controller?.setContentInsets(contentInset)
        }
    }
    @objc public var fallbackURL: String?
    @objc public var filename: String?
    @objc public var previewURL: String?

    public override func layoutSubviews() {
        guard let filename = filename, let fallbackURL = fallbackURL.flatMap({ URL(string: $0) }) else {
            return super.layoutSubviews()
        }
        let previewURL = self.previewURL.flatMap({ URL(string: $0) })
        if let controller = controller, fallbackURL != controller.fallbackURL || filename != controller.filename || previewURL != controller.previewURL {
            controller.unembed()
            self.controller = nil
        }
        if controller == nil {
            let controller = DocViewerViewController.create(filename: filename, previewURL: previewURL, fallbackURL: fallbackURL)
            parentViewController?.embed(controller, in: self)
            controller.setContentInsets(contentInset)
            controller.isAnnotatable = true
            self.controller = controller
        }
        super.layoutSubviews()
    }
}
