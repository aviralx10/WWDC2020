import SpriteKit

public class scene1: SKScene {

  override public func didMove(to view: SKView) {
    
    let player = childNode(withName: "player") as? SKSpriteNode
    player!.run(SKAction.repeatForever(
        SKAction.sequence([
            SKAction.moveBy(x: 0, y: 10, duration: 0.45),
            SKAction.moveBy(x: 0, y: -10, duration: 0.45)
            ]
    )))
    
    
    }
  
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        
        if let _ = touches.first {
                
                let scene = scene2(fileNamed: "scene2")!
                scene.scaleMode = .aspectFit
                let transition = SKTransition.flipVertical(withDuration: 1)
                self.view?.presentScene(scene, transition: transition)
            

        }
        
    }
}


