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

final class HorizonTabBar: UITabBar {
    // MARK: - Properties

    var didTapButton: (() -> Void)?
    public lazy var chatBotButton: UIButton = {
        let middleButton = UIButton()
        let image = UIImage(resource: .chatBot)
        middleButton.setImage(image, for: .normal)
        middleButton.addTarget(self, action: #selector(self.chatBotAction), for: .touchUpInside)
        self.addSubview(middleButton)
        return middleButton
    }()

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        configureShadow()
        removeTabBarBorder()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureShadow()
        removeTabBarBorder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonHeight = Double(frame.size.height / 1.2)
        chatBotButton.frame.size = CGSize(width: buttonHeight, height: buttonHeight)
        let xPoint = Double(frame.width / 2)
        let yPoint = buttonHeight / 2
        chatBotButton.center = CGPoint(x: xPoint, y: yPoint)
    }

    private func configureShadow() {
        self.layer.shadowColor = UIColor.textDarkest.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0)
        self.layer.shadowRadius = 10.0
        self.layer.shadowOpacity = 0.12
        self.layer.masksToBounds = false
    }

    private func removeTabBarBorder() {
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
    }

    // MARK: - Actions

    @objc private func chatBotAction(sender: UIButton) {
        didTapButton?()
    }
}
