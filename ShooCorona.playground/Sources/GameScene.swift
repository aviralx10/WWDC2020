import SpriteKit

public class GameScene: SKScene, SKPhysicsContactDelegate {
        
    let coronaSpeed: CGFloat = 80.0
    let playerspeed: CGFloat = 155.0
    
    var mask: SKSpriteNode?
    var player: SKSpriteNode?
    var mcorona: [SKSpriteNode] = []
    
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
        // </> Animations
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>,with event: UIEvent?) { handleTouches(touches)
        updatePlayer()
        updateZombies()
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,with event: UIEvent?) { handleTouches(touches)
        
    }
    
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
            updatePosition(for: player, to: touch, speed: playerspeed)
            
        } else {
            player.physicsBody?.isResting = true
        }
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
        //sprite.physicsBody?.isDynamic = true
        
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
            // Player & corona
            gameOver(false)
        } else if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask &&
            secondBody.categoryBitMask == mask?.physicsBody?.categoryBitMask {
            // Player & mask
            gameOver(true)
        }
        

    }
    fileprivate func gameOver(_ didWin: Bool) {
        let resultScene = MenuScene(size: size, didWin: didWin, levelToSend: 2)
        let transition = SKTransition.flipVertical(withDuration: 1.0)
        view?.presentScene(resultScene, transition: transition)
    }
    
}

