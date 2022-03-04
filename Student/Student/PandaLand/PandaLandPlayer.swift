//
//  Player.swift
//  PlatformerDemo
//
//  Created by MattBaranowski on 2/17/16.
//  Copyright © 2016 mattbaranowski. All rights reserved.
//

import SpriteKit

class PandaLandPlayer : SKSpriteNode {
    
    var desiredPosition : CGPoint = CGPoint.zero
    var velocity : CGPoint = CGPoint.zero
    
    var onGround : Bool = false
    var forward : Bool = false
    var backward : Bool = false
    var shouldJump : Bool = false
    
    static let gravity = CGPoint(x: 0.0, y: -1500.0)
    static let forwardMove = CGPoint(x: 2000.0, y: 0.0)
    static let dampeningForce = CGPoint(x: 0.9, y: 1)
    static let jumpForce = CGPoint(x: 0.0, y: 900)
    static let jumpCutoff : CGFloat = 150.0
    
    init() {
        let texture = SKTexture(imageNamed: "Panda")
        let playerScale = 0.75
        super.init(texture: texture, color: .white, size:CGSize(width: texture.size().width * playerScale, height: texture.size().height * playerScale))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(_ delta : TimeInterval) {
        let gravityStep = PandaLandPlayer.gravity * delta
        let forwardStep = PandaLandPlayer.forwardMove * delta
        
        velocity = (velocity + gravityStep) * PandaLandPlayer.dampeningForce;
        
        if shouldJump && onGround {
            velocity = velocity + PandaLandPlayer.jumpForce
        } else if !shouldJump && velocity.y > PandaLandPlayer.jumpCutoff {
            velocity = CGPoint(x:velocity.x, y:PandaLandPlayer.jumpCutoff)
        }
        
        if forward {
            xScale = 1
            velocity = velocity + forwardStep
        }
        
        if backward {
            xScale = -1
            velocity = velocity - forwardStep
        }
        
        let facingBack = velocity.x < 0
        xScale = facingBack ? -1.0 : 1.0
        
        desiredPosition = position + (velocity * delta)
    }
}
