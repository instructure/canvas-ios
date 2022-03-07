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

class PandaLandMenuScene: SKScene {

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        let xCenter = size.width / 2
        let yCenter = size.height / 2
        let pandaLogo = SKSpriteNode(imageNamed: "Panda")
        pandaLogo.position = CGPoint(x: xCenter, y: yCenter + 120)
        addChild(pandaLogo)
        let title = SKSpriteNode(imageNamed: "pandalandlogo")
        title.setScale(0.5)
        backgroundColor = .skyBlueColor()
        title.position = CGPoint(x: xCenter, y: yCenter + 50)
        addChild(title)

        let startLabel = SKLabelNode(text: "Play")
        let exitLabel = SKLabelNode(text: "Exit")
        startLabel.position = CGPoint(x: xCenter, y: yCenter - 75)
        exitLabel.position = CGPoint(x: xCenter, y: yCenter - 150)
        addChild(startLabel)
        addChild(exitLabel)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let touchedNode = atPoint(location) as? SKLabelNode {
                switch touchedNode.text {
                case "Play":
                    scene?.view?.presentScene(PandaLandGameScene(), transition: .crossFade(withDuration: 0.5))
                case "Exit":
                    break
                default:
                    break
                }
            }
        }
    }
}
