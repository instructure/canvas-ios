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

import UIKit

public class TextRecognizerTipOverlayView: UIView {
    private let bgView: UIView = {
        let blur = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: blur)
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()

    private let focusedView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.alpha = 0
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Position the text in the frame to scan it."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .textDarkest
        label.alpha = 0
        label.textAlignment = .center
        return label
    }()

    init() {
        super.init(frame: .zero)
        addSubview(bgView)
        addSubview(focusedView)
        addSubview(titleLabel)
        backgroundColor = .clear
        bgView.translatesAutoresizingMaskIntoConstraints = false
        focusedView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor),

            focusedView.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            focusedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            focusedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            focusedView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func animate() {
        UIView.animate(withDuration: 1, delay: 0.5) {
            self.titleLabel.alpha = 1
            self.focusedView.alpha = 1
            self.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 1, delay: 0.25) {
                self.titleLabel.alpha = 0
                self.bgView.alpha = 0
                self.layoutIfNeeded()
            }
        }
    }

    public func resetAnimation() {
        focusedView.alpha = 0
        titleLabel.alpha = 0
        bgView.alpha = 1
    }

}
