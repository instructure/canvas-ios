//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit

class FilePickerProgressView: UIView {

    public var header: DynamicLabel?
    private var progressView: UIProgressView?
    private var contentView: UIView?
    /**
     Progress from 0.0 to 1.0

     This will animate the private `progressView`
     */
    public var progress: Float = 0 {
        didSet {
            progressView?.setProgress(progress, animated: true)
        }
    }

    public var text: String? {
        get { return header?.text }
        set { header?.text = newValue }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }

    func commonSetup() {
        contentView = UIView()
        header = DynamicLabel()
        progressView = UIProgressView(progressViewStyle: .bar)

        let metrics = ["pad": 15]

        guard let contentView = contentView, let header = header, let progressView = progressView else { return }

        addSubview( contentView )
        contentView.pinToTopAndBottomOfSuperview()
        contentView.addConstraintsWithVFL("H:|-(pad)-[view]-(pad)-|", metrics: metrics)

        contentView.addSubview(header)
        header.pinToLeftAndRightOfSuperview()
        header.addConstraintsWithVFL("V:|-(pad)-[view]", metrics: metrics)

        contentView.addSubview( progressView )
        progressView.pinToLeftAndRightOfSuperview()
        progressView.addConstraintsWithVFL("V:[header]-(pad)-[view]", views: ["header": header], metrics: metrics)

        progressView.tintColor = .textInfo
        header.font = .scaledNamedFont(.medium16)
        header.textAlignment = .center
        header.textColor = .textInfo

        header.text = String(localized: "Uploading...", bundle: .core)
        progressView.backgroundColor = .backgroundLight
        progress = 0.75
    }
}
