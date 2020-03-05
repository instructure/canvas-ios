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

public protocol LTIControllerDelegate: class {
    func ltiControllerDidLaunchTool()
}

public class LTIViewController: UIViewController {
    public let tools: LTITools

    var spinner: UIActivityIndicatorView!
    var button: UIButton!

    public init(tools: LTITools) {
        self.tools = tools
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        button = UIButton(type: .system)
        button.setTitleColor(Brand.shared.buttonPrimaryText, for: .normal)
        button.backgroundColor = Brand.shared.buttonPrimaryBackground
        button.setTitle(NSLocalizedString("Launch External Tool", bundle: .core, comment: ""), for: .normal)
        button.titleLabel?.font = .scaledNamedFont(.semibold16)
        button.addTarget(self, action: #selector(launch), for: .primaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.layer.cornerRadius = 4
        button.sizeToFit()
        view.addSubview(button)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            button.widthAnchor.constraint(lessThanOrEqualToConstant: 285),
            button.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 45),
            button.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -45),
        ])

        spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
        ])
    }

    @objc func launch() {
        showLoading(true)
        tools.presentTool(from: self, animated: true) { [weak self] _ in
            self?.showLoading(false)
        }
    }

    func showLoading(_ loading: Bool) {
        loading ? spinner.startAnimating() : spinner.stopAnimating()
        button.isHidden = loading
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("not supported")
    }
}
