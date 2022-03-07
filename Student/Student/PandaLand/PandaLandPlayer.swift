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
    static let jumpForce = CGPoint(x: 0.0, y: 950)
    static let jumpCutoff : CGFloat = 150.0

    private var walkSequence: [SKTexture] = []
    private var isAnimating = false

    private let jumpSound = SKAction.playSoundFileNamed("jump", waitForCompletion: true)
    
    init() {
        let atlas = SKTextureAtlas(named: "PandaLandPlayer")
        for i in 0..<atlas.textureNames.count {
            walkSequence.append(atlas.textureNamed("frame_\(i)"))
        }
        let texture = walkSequence[10]
        super.init(texture: texture, color: .white, size:CGSize(width: texture.size().width, height: texture.size().height))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func animateMove() {
        isAnimating = true
        run(.repeatForever(.animate(with: walkSequence, timePerFrame: 0.05, resize: false, restore: true)), withKey: "walkSequence")
    }

    func stopAnimateMove() {
        removeAction(forKey: "walkSequence")
        isAnimating = false
    }
    
    func update(_ delta : TimeInterval) {
        let gravityStep = PandaLandPlayer.gravity * delta
        let forwardStep = PandaLandPlayer.forwardMove * delta
        
        velocity = (velocity + gravityStep) * PandaLandPlayer.dampeningForce;
        let clampedYvelocity = min(max(velocity.y, -1000), 1000)
        velocity = CGPoint(x: velocity.x, y: clampedYvelocity)
        
        if shouldJump && onGround {
            velocity = velocity + PandaLandPlayer.jumpForce
            removeAction(forKey: "jumpSound")
            run(jumpSound, withKey: "jumpSound")
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

        if !forward && !backward && !shouldJump  {
            stopAnimateMove()
            texture = walkSequence[9]
        } else if !isAnimating && onGround {
            animateMove()
        }

        if shouldJump {
            stopAnimateMove()
            texture = walkSequence[7]
        }
        
        let facingBack = velocity.x < 0
        xScale = facingBack ? -1.0 : 1.0
        
        desiredPosition = position + (velocity * delta)
    }
}
