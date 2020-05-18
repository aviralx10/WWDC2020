import SpriteKit
//import UIKit

public class GameScene3: SKScene, SKPhysicsContactDelegate {
    
    let playerSpeed: CGFloat = 155.0
    let coronaSpeed: CGFloat = 40.0
    let sanitizerDuration: Double = 6.0
    
    var mask: SKSpriteNode?
    var player: SKSpriteNode?
    var sanitizer: SKSpriteNode?
    var mcorona: [SKSpriteNode] = []
    var powerup: Bool = false
    var powerupCount: Int = 0
    
    var lastTouch: CGPoint? = nil
    
    override public func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        // Animations
        player = childNode(withName: "player") as? SKSpriteNode
        
        mask = childNode(withName: "mask") as? SKSpriteNode
        mask!.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.moveBy(x: 0, y: 10, duration: 0.45),
                SKAction.moveBy(x: 0, y: -10, duration: 0.45)
                ]
        )))
        
        for child in self.children {
            if child.name == "corona" {
                if let child = child as? SKSpriteNode {
                    mcorona.append(child)
                }
            }
        }
        
        sanitizer = childNode(withName: "sanitizer") as? SKSpriteNode
        for child in self.children {
            if child.name == "sanitizer" {
                if let child = child as? SKSpriteNode {
                    child.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(3.14), duration: 4.0)))
                }
            }
        }
        // </> Animations

    }
    
    override public func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?) { handleTouches(touches) }
    
    override public func touchesMoved(_ touches: Set<UITouch>,with event: UIEvent?) { handleTouches(touches) }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { handleTouches(touches) }
    
    fileprivate func handleTouches(_ touches: Set<UITouch>) { lastTouch = touches.first?.location(in: self) }
    
    override public func didSimulatePhysics() {
        if player != nil {
            updatePlayer()
            updateZombies()
        }
    }
    
    fileprivate func shouldMove(currentPosition: CGPoint,
                                touchPosition: CGPoint) -> Bool {
        guard let player = player else { return false }
        return abs(currentPosition.x - touchPosition.x) > player.frame.width / 2 ||
            abs(currentPosition.y - touchPosition.y) > player.frame.height / 2
    }
    
    fileprivate func updatePlayer() {
        guard let player = player,
            let touch = lastTouch
            else { return }
        let currentPosition = player.position
        if shouldMove(currentPosition: currentPosition,
                      touchPosition: touch) {
            updatePosition(for: player, to: touch, speed: playerSpeed)
            updateCamera()
        } else {
            player.physicsBody?.isResting = true
        }
    }
    
    fileprivate func updateCamera() {
        guard let player = player else { return }
        camera?.position = player.position
    }
    
    func updateZombies() {
        guard let player = player else { return }
        let targetPosition = player.position
        
        for corona in mcorona {
            updatePosition(for: corona, to: targetPosition, speed: coronaSpeed)
        }
    }
    func getDuration(pointA:CGPoint,pointB:CGPoint,speed:CGFloat)->TimeInterval{
        let xDist = (pointB.x - pointA.x)
        let yDist = (pointB.y - pointA.y)
        let distance = sqrt((xDist * xDist) + (yDist * yDist));
        let duration : TimeInterval = TimeInterval(distance/speed)
        return duration
    }
    
    fileprivate func updatePosition(for sprite: SKSpriteNode, to target: CGPoint, speed: CGFloat) {
        
        let currentPosition = sprite.position
        let angle = CGFloat.pi + atan2(currentPosition.y - target.y, currentPosition.x - target.x)
        let rotateAction = SKAction.rotate(toAngle: angle + (CGFloat.pi*0.5), duration: 0)
        sprite.run(rotateAction)
        
        let velocityX = speed * cos(angle)
        let velocityY = speed * sin(angle)
        
        let newVelocity = CGVector(dx: velocityX, dy: velocityY)
        sprite.physicsBody?.velocity = newVelocity
        sprite.physicsBody?.affectedByGravity = false
        let moveToTouch = SKAction.move(to: CGPoint(x: target.x, y: target.y),duration: getDuration(pointA:currentPosition,pointB:target,speed:speed))
        sprite.run(moveToTouch)
    }

    public func didBegin(_ contact: SKPhysicsContact) {

        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody

        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        // Check contact
        if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == mcorona[0].physicsBody?.categoryBitMask {
            // Player & Corona
            if !powerup { gameOver(false) }
            
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == mask?.physicsBody?.categoryBitMask {
            // Player & mask
            guard let nextScene = sceneFinal(fileNamed: "sceneFinal") else { fatalError("GameScene not found") }
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            nextScene.scaleMode = .aspectFit
            view?.presentScene(nextScene, transition: transition)
            //gameOver(true)
            
        }else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == sanitizer?.physicsBody?.categoryBitMask {
            // Player & sanitizer
            let sanitizer = secondBody.node as! SKSpriteNode
            sanitizer.removeFromParent()
            self.gainPowerUp()
            
        }
    }
    
    func gainPowerUp() {
        powerup = true
        powerupCount += 1
        
        // different animation
        player?.run(SKAction.repeat(
            SKAction.sequence([
                SKAction.setTexture(SKTexture(imageNamed: "Strong")),
                SKAction.moveBy(x: 0, y: 0, duration: 0.15),
                SKAction.setTexture(SKTexture(imageNamed: "player")),
                SKAction.moveBy(x: 0, y: 0, duration: 0.15),
                ]
        ), count: 20
        ))
        
        player?.texture = SKTexture(imageNamed: "Strong")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + self.sanitizerDuration) {
            if self.powerupCount <= 1 { self.powerup = false }
            self.powerupCount -= 1
        }
    }
        
    fileprivate func gameOver(_ didWin: Bool) {
        
        if !didWin {
            let resultScene = MenuScene(size: size, didWin: didWin, levelToSend: 4)
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            view?.presentScene(resultScene, transition: transition)
        }
        else{
            guard let nextScene = sceneFinal(fileNamed: "sceneFinal") else { fatalError("GameScene not found") }
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            nextScene.scaleMode = .aspectFit
            view?.presentScene(nextScene, transition: transition)
        }
        
        
    }

}


