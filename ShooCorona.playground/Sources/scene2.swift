import SpriteKit

public class scene2: SKScene {

  override public func didMove(to view: SKView) {
    
    for child in self.children {
        
        if child.name == "corona" {
            if let corona = child as? SKSpriteNode {
                
//                corona.run(SKAction.repeatForever(
//                    SKAction.sequence([
//                        SKAction.moveBy(x: 0, y: 900, duration: 15),
//                        SKAction.moveBy(x: 0, y: -900, duration: 0),
//                        ] )))
//
                corona.run(SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.moveBy(x: 10, y: 0, duration: 0.30),
                        SKAction.moveBy(x: -10, y: 0, duration: 0.30),
                        ])))
            }
        }
        
        if child.name == "player" {
            if let player = child as? SKSpriteNode {
                
//                player.run(SKAction.repeatForever(
//                    SKAction.sequence([
//                        SKAction.moveBy(x: 0, y: 900, duration: 15),
//                        SKAction.moveBy(x: 0, y: -900, duration: 0),
//                        ])))
//                
                player.run(SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.moveBy(x: 10, y: 0, duration: 0.30),
                        SKAction.moveBy(x: -10, y: 0, duration: 0.30),
                        ])))
            }
        }
    }
    
    
    }
  
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?) {
        
        if let _ = touches.first {
            
                let scene = scene3(fileNamed: "scene3")!
                scene.scaleMode = .aspectFit
                let transition = SKTransition.flipVertical(withDuration: 1)
                self.view?.presentScene(scene, transition: transition)
        }
    }
}


