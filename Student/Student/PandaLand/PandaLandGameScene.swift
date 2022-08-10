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

import Core
import SwiftUI
import SpriteKit
import GameplayKit
import AVFoundation

class PandaLandGameScene: SKScene {

    var map : JSTileMap = JSTileMap(named: "map.tmx")
    var player = PandaLandPlayer()
    var previousUpdate : CFTimeInterval = 0
    let initialPosition = CGPoint(x: 100, y: 400)
    let cameraNode = SKCameraNode()
    let exitLabel = SKLabelNode(text: "Exit")
    let timerLabel = SKLabelNode(text: "0.0")
    let coinLabel = SKLabelNode(text: "30")
    let bgMusic = SKAudioNode(fileNamed: "bgMusic.mp3")
    let coinSound = SKAction.playSoundFileNamed("coin", waitForCompletion: false)
    var timer = Timer()
    var counter = 0.0
    var bgMusicOn = true {
        didSet {
            bgMusic.run(SKAction.changeVolume(to: Float(bgMusicOn ? 0.3 : 0), duration: 0.25))
        }
    }
    var coinCount = 30 {
        didSet {
            coinLabel.text = "\(coinCount)"
        }
    }

    override func didMove(to view: SKView) {
        addChild(cameraNode)
        camera = cameraNode
        let cameraScale = 1.5
        cameraNode.setScale(cameraScale)
        backgroundColor = .skyBlueColor()
        addChild(map)
        player.position = initialPosition
        player.zPosition = 8000
        map.addChild(player)
        let controls = PandaLandControls(with: self.size)
        controls.zPosition = 9000
        cameraNode.addChild(controls)
        cameraNode.addChild(labelNode(with: self.size))
        view.isMultipleTouchEnabled = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
        bgMusic.run(SKAction.changeVolume(to: Float(0.3), duration: 0))
        self.addChild(bgMusic)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc func updateTimer() {
        counter = counter + 0.1
        timerLabel.text = String(format: "%.1f", counter)
    }

    func labelNode(with sceneSize: CGSize) -> SKNode {
        let node = SKNode()
        let yPosition = sceneSize.height / 2 - 70
        exitLabel.position = CGPoint(x: -sceneSize.width / 2 + 30, y: yPosition)
        exitLabel.name = "exitLabel"
        timerLabel.position = CGPoint(x: 0, y: yPosition)
        timerLabel.name = "timerLabel"
        coinLabel.position = CGPoint(x: sceneSize.width / 2 - 30, y: yPosition)
        let coinLogo = SKSpriteNode(imageNamed: "student-logomark")
        coinLogo.size = CGSize(width: 22, height: 22)
        coinLogo.position = CGPoint(x: sceneSize.width / 2 - 62, y: yPosition + 11)
        node.addChild(coinLogo)
        node.addChild(exitLabel)
        node.addChild(coinLabel)
        node.addChild(timerLabel)
        return node
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

    func onPlayerDied() {
        delay(500, closure: DispatchWorkItem {
            self.player.run(.move(to: self.initialPosition, duration: 1))
            //self.player.position =  self.initialPosition
            self.player.velocity = CGPoint.zero
        })
    }

    func endGame() {
        timer.invalidate()
    }

    enum KeyCode : Int {
        case jump = 32
        case forward = 100
        case backward = 97
    }

    func playerAction(_ keyCode : KeyCode, activate : Bool) {
        switch keyCode {
        case .jump:      player.shouldJump = activate
        case .forward:   player.forward = activate
        case .backward:  player.backward = activate
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
            let location = touch.location(in: self)
            if let touchedNode = atPoint(location) as? SKSpriteNode {
                switch touchedNode.name {
                case "leftButton":
                    touchedNode.colorBlendFactor = activate ? 1.0 : 0.0
                    playerAction(.backward, activate: activate)
                case "rightButton":
                    touchedNode.colorBlendFactor = activate ? 1.0 : 0.0
                    playerAction(.forward, activate: activate)
                case "upButton":
                    touchedNode.colorBlendFactor = activate ? 1.0 : 0.0
                    playerAction(.jump, activate: activate)
                default:
                    break
                }
            } else if let touchedNode = atPoint(location) as? SKLabelNode {
                switch touchedNode.name {
                case "exitLabel":
                    scene?.view?.presentScene(nil)
                    AppEnvironment.shared.topViewController?.dismiss(animated: true)
                case "timerLabel":
                    bgMusicOn.toggle()
                default:
                    break
                }
            }
        }
    }

    override func update(_ currentTime: CFTimeInterval) {
        let delta = clamp(lower:0.0, upper:0.2, currentTime - previousUpdate)
        previousUpdate = currentTime
        player.update(delta)
        let cameraPosition = CGPoint(x: player.position.x + player.xScale * 100, y: player.position.y)
        let moveCamera = SKAction.move(to: cameraPosition, duration: 0.25)
        cameraNode.run(moveCamera)
        cameraNode.position = cameraPosition
        handleCollisions(player, layer: map.layerNamed("walls"))
        handlePickups(player, layer: map.layerNamed("gems"))
    }
}

struct PandaLandSceneView: View {

    var scene: PandaLandGameScene {
        let scene = PandaLandGameScene()
        scene.size = CGSize(width: 414, height: 896)
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


extension PandaLandGameScene {
    func handleCollisions(_ player : PandaLandPlayer, layer : TMXLayer) {
        player.onGround = false

        var adjustment = CGPoint.zero
        var velocityFactor = CGPoint(x:1,y:1)

        for direction in Direction.All {
            let playerCoord = layer.coord(for: player.desiredPosition)

            if playerCoord.y > map.mapSize.height {
                onPlayerDied()
                return
            }

            let offset = direction.offset()
            let tileCoord = playerCoord + offset;

            if tileGID(tileCoord, forLayer:layer) != 0 {
                let tileRect = tileRect(tileCoord)

                if player.frame.offsetBy(dx: 0, dy: 4).intersects(tileRect) {

                    let intersection = player.frame.offsetBy(dx: 0, dy: 4).intersection(tileRect)

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

                        if intersection.size.width > intersection.size.height {

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

    func handlePickups(_ player : PandaLandPlayer, layer : TMXLayer) {
        for direction in Direction.All {
            let playerCoord = layer.coord(for: player.desiredPosition)
            let offset = direction.offset()
            let tileCoord = playerCoord + offset;

            if tileGID(tileCoord, forLayer:layer) == 30 {
                let tileRect = tileRect(tileCoord).insetBy(dx: 32, dy: 32)

                if player.frame.offsetBy(dx: 0, dy: 4).intersects(tileRect) {
                    if let sparkle = SKEmitterNode(fileNamed: "PandaParticle.sks") {
                        sparkle.position = tileRect.offsetBy(dx: tileRect.width / 2, dy: tileRect.height / 2).origin
                        sparkle.particleColor = .yellow
                        layer.removeTile(atCoord: tileCoord)
                        coinCount = layer.children.first?.children.count ?? 0
                        removeAction(forKey: "coinSound")
                        run(coinSound, withKey: "coinSound")
                        if coinCount <= 0 {
                            endGame()
                        }
                        map.addChild(sparkle)
                    }
                }
            }
        }
    }

    func tileGID(_ tileCoords:CGPoint, forLayer layer:TMXLayer) -> Int32 {
        let size = layer.layerInfo.layerGridSize

        if tileCoords.x >= size.width || tileCoords.y >= size.height || tileCoords.x < 0 || tileCoords.y < 0 {
            return 0
        }
        return layer.layerInfo.tileGid(atCoord: tileCoords)
    }

    func tileRect(_ tileCoords : CGPoint) -> CGRect {
        let levelHeightInPixels = mapPixelSize.height
        let origin = CGPoint(x:tileCoords.x * map.tileSize.width,
            y:levelHeightInPixels - ((tileCoords.y + 1) * map.tileSize.height));
        return CGRect(x: origin.x, y: origin.y, width: map.tileSize.width, height: map.tileSize.height);
    }

    var mapPixelSize : CGSize {
        get { return CGSize(width: map.mapSize.width  * map.tileSize.width,
            height: map.mapSize.height * map.tileSize.height )
        }
    }
}
