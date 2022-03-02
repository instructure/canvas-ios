//
//  Player.swift
//  PlatformerDemo
//
//  Created by MattBaranowski on 2/17/16.
//  Copyright © 2016 mattbaranowski. All rights reserved.
//

import SpriteKit

class Player : SKSpriteNode {
    
    var desiredPosition : CGPoint = CGPoint.zero
    var velocity : CGPoint = CGPoint.zero
    
    var onGround : Bool = false
    var forward : Bool = false
    var backward : Bool = false
    var shouldJump : Bool = false
    
    static let gravity = CGPoint(x: 0.0, y: -1000.0)
    static let forwardMove = CGPoint(x:2000.0, y:0.0)
    static let dampeningForce = CGPoint(x: 0.9, y: 1.0)
    static let jumpForce = CGPoint(x:0.0, y:500)
    static let jumpCutoff : CGFloat = 150.0
    
    init() {
        let texture = SKTexture(imageNamed: "Panda")
        super.init(texture: texture, color: .white, size:texture.size() )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(_ delta : TimeInterval) {
        let gravityStep = Player.gravity * delta
        let forwardStep = Player.forwardMove * delta
        
        self.velocity = (self.velocity + gravityStep) * Player.dampeningForce;
        
        if self.shouldJump && self.onGround {
            self.velocity = self.velocity + Player.jumpForce
        } else if !self.shouldJump && self.velocity.y > Player.jumpCutoff {
            self.velocity = CGPoint(x:self.velocity.x, y:Player.jumpCutoff)
        }
        
        if self.forward {
            self.velocity = self.velocity + forwardStep
        }
        
        if self.backward {
            self.velocity = self.velocity - forwardStep
        }
        
        let facingBack = self.velocity.x < 0
        self.xScale = facingBack ? -1.0 : 1.0
        
        self.desiredPosition = self.position + (self.velocity * delta)
    }
}
