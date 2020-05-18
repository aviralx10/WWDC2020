import SpriteKit

public class scene4: SKScene {

//  override public func didMove(to view: SKView) {
//
//    let sanitizer = childNode(withName: "sanitizer") as? SKSpriteNode
//   // sanitizer!.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(3.14), duration: 7.0)))
//    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
                let scene = GameScene2(fileNamed: "GameScene2")!
                scene.scaleMode = .aspectFit
                let transition = SKTransition.flipVertical(withDuration: 1)
                self.view?.presentScene(scene, transition: transition)
            
    }
}


