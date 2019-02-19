//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
            progressView?.setProgress(progress, animated: !ProcessInfo.isUITest) // workaround EarlGrey crash
        }
    }

    public var text: String? {
        set { header?.text = newValue }
        get { return header?.text }
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

        progressView.tintColor = .named(.electric)
        header.font = .scaledNamedFont(.title3)
        header.textAlignment = .center
        header.textColor = .named(.electric)

        header.text = NSLocalizedString("Uploading...", comment: "")
        progressView.backgroundColor = .named(.backgroundLight)
        progress = 0.75
    }
}
