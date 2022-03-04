//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import SpriteKit

class PandaLandControls: SKNode {

    let leftButton = SKSpriteNode(imageNamed: "button_left")
    let rightButton = SKSpriteNode(imageNamed: "button_right")
    let upButton = SKSpriteNode(imageNamed: "button_up")


    init(with sceneSize: CGSize) {
        super.init()
        leftButton.name = "leftButton"
        rightButton.name = "rightButton"
        upButton.name = "upButton"
        let buttonSize = leftButton.size.width
        let yPosition = -sceneSize.height / 2 + 150
        leftButton.position = CGPoint(x: -sceneSize.width / 2 + buttonSize / 2 , y: yPosition)
        rightButton.position = CGPoint(x: leftButton.position.x + buttonSize, y: yPosition)
        upButton.position = CGPoint(x: sceneSize.width / 2 - buttonSize / 2, y: yPosition)
        addChild(leftButton)
        addChild(rightButton)
        addChild(upButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
