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

import SwiftUI
import SpriteKit
import GameplayKit

class PandaLandScene: SKScene {

    var map : JSTileMap = JSTileMap(named: "map.tmx")
    var player = Player()
    var previousUpdate : CFTimeInterval = 0
    let initialPosition = CGPoint(x: 100, y: 400)
    //let cameraNode = SKCameraNode()

    override func didMove(to view: SKView) {
        //scene?.addChild(cameraNode)
        //scene?.camera = cameraNode
        //cameraNode.setScale(2)
        self.scene?.setScale(2)
        self.backgroundColor = .skyBlueColor()
        self.addChild(map)
        self.player.position = self.initialPosition
        self.map.addChild(self.player)
    }

    override func update(_ currentTime: CFTimeInterval) {
        let delta = clamp(lower:0.0, upper:0.2, currentTime - self.previousUpdate)
        self.previousUpdate = currentTime

        self.player.update(delta)
        self.handleCollisions(player, layer: self.map.layerNamed("walls"))
        self.setViewpointCenter(self.player.position)
    }

    enum Direction : Int {
        case above
        case below
        case left
        case right
        case upperLeft
        case upperRight
        case lowerLeft
        case lowerRight

        func offset() -> CGPoint {
            switch self {
            case .above:         return CGPoint(x: 0,y:-1)
            case .below:         return CGPoint(x: 0,y: 1)
            case .left:          return CGPoint(x:-1,y: 0)
            case .right:         return CGPoint(x: 1,y: 0)
            case .upperLeft:     return CGPoint(x:-1,y: 1)
            case .upperRight:    return CGPoint(x: 1,y: 1)
            case .lowerLeft:     return CGPoint(x:-1,y:-1)
            case .lowerRight:    return CGPoint(x: 1,y:-1)
            }
        }

        static let All : [Direction] = [.above,.below,.left,.right,.upperLeft,.upperRight,.lowerLeft,.lowerRight]
    }

    func handleCollisions(_ player : Player, layer : TMXLayer) {
        self.player.onGround = false

        var adjustment = CGPoint.zero
        var velocityFactor = CGPoint(x:1,y:1)

        for direction in Direction.All {
            let playerCoord = layer.coord(for: player.desiredPosition)

            if playerCoord.y > self.map.mapSize.height {
                self.onPlayerDied()
                return
            }

            let offset = direction.offset()
            let tileCoord = playerCoord + offset;

            if self.tileGID(tileCoord, forLayer:layer) != 0 {
                let tileRect = self.tileRect(tileCoord)

                if player.frame.intersects(tileRect) {

                    let intersection = player.frame.intersection(tileRect)

                    switch direction {
                    case .below:
                        adjustment += CGPoint(x:0, y:intersection.size.height)
                        velocityFactor *= CGPoint(x:1,y:0)
                        player.onGround = true

                    case .above:
                        adjustment += CGPoint(x:0, y:-intersection.size.height)
                        velocityFactor *= CGPoint(x:1,y:0)
                        break;

                    case .left:
                        adjustment += CGPoint(x:intersection.size.width, y:0)

                    case .right:
                        adjustment += CGPoint(x:-intersection.size.width, y:0)

                    default:

                        if intersection.size.width > intersection.size.height { //tile is diagonal, but resolving collision vertically

                            velocityFactor *= CGPoint(x:1,y:0)
                            if direction.offset().y == 1 {
                                player.onGround = true
                            }

                            adjustment += CGPoint(x:0, y: offset.y * intersection.size.height)
                        } else  {
                            adjustment += CGPoint(x: -offset.x * intersection.size.width, y:0)
                        }
                    }
                }
            }
        }

        player.velocity *= velocityFactor
        player.position = player.desiredPosition + adjustment
    }

    func onPlayerDied() {
        delay(1000, closure: DispatchWorkItem {
            self.player.position =  self.initialPosition
            self.player.velocity = CGPoint.zero
        })
    }

    func tileGID(_ tileCoords:CGPoint, forLayer layer:TMXLayer) -> Int32 {
        let size = layer.layerInfo.layerGridSize

        if tileCoords.x >= size.width || tileCoords.y >= size.height || tileCoords.x < 0 || tileCoords.y < 0 {
            return 0
        }
        return layer.layerInfo.tileGid(atCoord: tileCoords)
    }

    func tileRect(_ tileCoords : CGPoint) -> CGRect {
        let levelHeightInPixels = self.mapPixelSize.height
        let origin = CGPoint(x:tileCoords.x * self.map.tileSize.width,
            y:levelHeightInPixels - ((tileCoords.y + 1) * self.map.tileSize.height));
        return CGRect(x: origin.x, y: origin.y, width: self.map.tileSize.width, height: self.map.tileSize.height);
    }

    // full size of the map in pixels
    var mapPixelSize : CGSize {
        get { return CGSize(width: self.map.mapSize.width  * self.map.tileSize.width,
            height: self.map.mapSize.height * self.map.tileSize.height )
        }
    }

    enum KeyCode : Int {
        case jump = 32
        case forward = 100
        case backward = 97
    }

    func playerAction(_ keyCode : KeyCode, activate : Bool) {
        switch keyCode {
        case .jump:      self.player.shouldJump = activate
        case .forward:   self.player.forward = activate
        case .backward:  self.player.backward = activate
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handle(touches: touches, activate: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handle(touches: touches, activate: false)
    }

    func handle(touches: Set<UITouch>, activate: Bool) {
        for touch in touches {
            let location = touch.location(in: self.view)
            if location.y > self.view?.frame.size.height ?? 0 / 2 {
                playerAction(.jump, activate: activate)
            } else {
                if location.x > self.view?.frame.size.width ?? 0 / 2 {
                    playerAction(.forward, activate: activate)
                } else {
                    playerAction(.backward, activate: activate)
                }
            }
        }
    }

    // half of the scene view size
    var halfViewPoint : CGPoint {
        get { return CGPoint(x:self.size.width * 0.5, y:self.size.height * 0.5) }
    }

    // full size of the map in pixels
    var mapMaxPoint : CGPoint {
        get { return CGPoint(x: self.map.mapSize.width  * self.map.tileSize.width,
            y: self.map.mapSize.height * self.map.tileSize.height )
        }
    }

    func setViewpointCenter(_ pos : CGPoint) {
        let actualPosition = clamp(lower: self.halfViewPoint, upper: self.mapMaxPoint - self.halfViewPoint, pos)
        self.map.position = (self.halfViewPoint - actualPosition)
        //cameraNode.position = actualPosition
    }
}

struct PandaLandSceneView: View {
    var scene: SKScene {
        let scene = PandaLandScene()
        scene.size = CGSize(width: 320, height: 586)
        scene.scaleMode = .aspectFill
        return scene
    }

    var body: some View {
        if #available(iOS 14.0, *) {
            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}
