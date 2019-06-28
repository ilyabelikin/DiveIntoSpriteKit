//
//  GameScene.swift
//  DiveIntoSpriteKit
//
//  Created by Paul Hudson on 16/10/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit
import CoreMotion

@objcMembers
class GameScene: SKScene, SKPhysicsContactDelegate {
    let motionManager = CMMotionManager()
    
    var junkTimer: Timer?
    var energyTimer: Timer?

    let player = SKSpriteNode(imageNamed: "player-rocket.png")
    
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
    
    var allowedRect : CGRect  {
       frame.insetBy(dx: -400, dy: -400)
    }
    
    var score = 0 {
        didSet { scoreLabel.text = "ENERGY: \(score)" }
    }
    
    let density : CGFloat = 0.7
    
    let playerInfo = UserDefaults.standard
    
    let playerCategory: UInt32 = 0x1 << 0
    let junkCategory: UInt32 = 0x1 << 1
    let bonusCategory: UInt32 = 0x1 << 2

    let soundOfExplosion = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    let soundOFBonus = SKAction.playSoundFileNamed("bonus.wav", waitForCompletion: false)
    
    var gameCounter = 1

    override func didMove(to view: SKView) {

        motionManager.startAccelerometerUpdates()
        physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "space.jpg")
        background.zPosition = -1
        addChild(background)
        
        scoreLabel.zPosition = 2
        scoreLabel.position.y = 300
        addChild(scoreLabel)
        
        score = 0
        
        if let particles = SKEmitterNode(fileNamed: "SpaceDust") {
            particles.advanceSimulationTime(10)
            particles.position.x = 512
            particles.zPosition = 1
            addChild(particles)
        }
        
        player.position.x = -350
        player.zPosition = 0
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = playerCategory | junkCategory | bonusCategory
        player.physicsBody?.collisionBitMask = junkCategory
        player.physicsBody?.angularDamping = 0.25
        player.physicsBody?.density = density
        
        addChild(player)
        
        junkTimer = Timer.scheduledTimer(timeInterval: 0.45, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
        energyTimer = Timer.scheduledTimer(timeInterval: 1.6, target: self, selector: #selector(createBonus), userInfo: nil, repeats: true)
        
        print("Initial setup is done. IgnoreSiblingOrder is \(self.view!.ignoresSiblingOrder)")
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user touches the screen
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // this method is called when the user stops touching the screen
    }

    override func update(_ currentTime: TimeInterval) {
        // this method is called before each frame is rendered
        
        if let accelerometerData = motionManager.accelerometerData {
            let changeX = CGFloat(accelerometerData.acceleration.y) * 40
            let changeY = CGFloat(accelerometerData.acceleration.x) * 40
          
//            Arcade style controls
//            player.position.x -= changeX
//            player.position.y += changeY
            
            let currentV = player.physicsBody!.velocity
            let newV = CGVector(dx: currentV.dx - changeX, dy: currentV.dy + changeY )
            player.physicsBody?.velocity = newV
            
            // zRotation stabilization, not ideal but kind of works
            if player.zRotation > 0.06 || player.zRotation < -0.06  {
                let direction = player.zRotation > 0 ? -0.01 : 0.01
                player.physicsBody?.applyTorque(CGFloat(direction))
            }
            else {
                player.zRotation = 0
            }
            // print("player at x: \(player.position.x) y: \(player.position.y)")

        }

        for node in children {
            if !allowedRect.contains(node.position) {
                if node == player {
                    print("Killing player")
                    self.gameOver(node: nil)
                }
                node.removeFromParent()
            }
        }
    }
    
    func createEnemy() {
        let sprite = SKSpriteNode(imageNamed: "space-junk")
        
        let spawnRect = allowedRect.insetBy(dx: 50, dy: 50)
        sprite.position = CGPoint(x: Int(spawnRect.maxX),
                                  y: Int(CGFloat.random(in: spawnRect.minY...spawnRect.maxY)))
        sprite.name = "enemy"
        sprite.zPosition = 0
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.density = density
        
        sprite.physicsBody?.categoryBitMask = junkCategory
        sprite.physicsBody?.contactTestBitMask = playerCategory | junkCategory | bonusCategory
        sprite.physicsBody?.collisionBitMask = playerCategory | junkCategory | bonusCategory

        
        sprite.physicsBody?.velocity = CGVector(dx: CGFloat(-Int.random(in: 100...800)), dy: CGFloat(Int.random(in: -8...8)))
        
        addChild(sprite)
    }
    
    func createBonus() {
        let sprite = SKSpriteNode(imageNamed: "energy.png")
   
        let spawnRect = allowedRect.insetBy(dx: 50, dy: 50)
        sprite.position = CGPoint(x: Int(spawnRect.maxX),
                                  y: Int(CGFloat.random(in: spawnRect.minY...spawnRect.maxY)))
        sprite.name = "bonus"
        sprite.zPosition = 0
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.density = 1

        sprite.physicsBody?.categoryBitMask = bonusCategory
        sprite.physicsBody?.contactTestBitMask = playerCategory | junkCategory | bonusCategory
        sprite.physicsBody?.collisionBitMask = junkCategory | bonusCategory

        
        sprite.physicsBody?.velocity = CGVector(dx: CGFloat(-Int.random(in: 250...900)), dy: CGFloat(Int.random(in: -25...25)))
        
        addChild(sprite)
        
    }
    
    
    // SKPhysicsContactDelegate protocol call for colisions
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerHit(nodeB)
        } else if nodeB == player {
            playerHit(nodeA)
        }
    }
    
    func playerHit (_ node: SKNode ) {
        if node.name == "bonus" {
            score += 1
            run(soundOFBonus)
            node.removeFromParent()
            return
        }
       
        // TODO: calculate impact and based damandge on it
        //if let v = node.physicsBody?.velocity {
        //
        //}
        player.alpha -= 0.1
       
        if player.alpha < 0 {
            gameOver(node: node)
        }
    }

    func gameOver (node: SKNode?) {
        if let node = node {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = player.position
                
                if let v = node.physicsBody?.velocity {
                    explosion.xAcceleration = v.dx * 5
                    explosion.yAcceleration = v.dy * 3
                }
                explosion.zPosition = 3
                addChild(explosion)
                run(soundOfExplosion)
            }
        }
        
        player.removeFromParent()
        
        let gameOverLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        gameOverLabel.fontSize = 80
        gameOverLabel.zPosition = 5
        gameOverLabel.position.y = 0
        gameOverLabel.text = "Game Over"
        
        if gameCounter > 1 {
            gameOverLabel.text?.append(" (\(gameCounter))")
        }
        
        addChild(gameOverLabel)
        
        let bestScoresLabel = SKLabelNode(fontNamed: "AvenirNextCondensed-Bold")
        bestScoresLabel.position.y = 250
        
        let bestScores : [Int] = playerInfo.array(forKey: "bestScores") as? [Int] ?? [0]
        var topThree  = Array(bestScores.sorted(by: {$0 > $1}).prefix(3))
        
        var bestScoresText: String = ""
        
        if score > topThree.first!  {
            bestScoresText.append("This is the new best! ")
        } else if score >= topThree.last! {
           bestScoresText.append("You made it in the Top 3! ")
        }
        
        // Adding current score, saving back to defaults
        topThree.append(score)
        topThree = Array(topThree.sorted(by: {$0 > $1}).prefix(3))
        playerInfo.set(topThree, forKey: "bestScores")
        
        let topScroesList: [String] = topThree.map({String($0)})
        
        bestScoresText.append("The best: \(topScroesList.joined(separator: ", ")).")
        bestScoresLabel.text = bestScoresText
        
        addChild(bestScoresLabel)
        
        junkTimer?.invalidate()
        junkTimer = nil
        
        energyTimer?.invalidate()
        energyTimer = nil
        
        // Each new game scene is slower loosing FPS
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                scene.gameCounter = self.gameCounter + 1
                self.view?.presentScene(scene)
            }
        }
    }
}

