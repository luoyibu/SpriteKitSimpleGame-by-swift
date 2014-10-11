//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by luoxuan-mac on 14-10-8.
//  Copyright (c) 2014年 luoyibu. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    
    var monsters: NSMutableArray
    var projectiles: NSMutableArray
    var monstersDestroyed: Int
    let projectileSoundEffectAction: SKAction
    let bgmPlayer: AVAudioPlayer
    
    override init(size: CGSize) {
        
        self.monsters = NSMutableArray()
        self.projectiles = NSMutableArray()
        self.projectileSoundEffectAction = SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false)
        self.monstersDestroyed = 0
        
        let bgmPath = NSBundle.mainBundle().pathForResource("background-music-aac", ofType: "caf")
        self.bgmPlayer = AVAudioPlayer(contentsOfURL: NSURL(string: bgmPath!), error: nil)
        self.bgmPlayer.numberOfLoops = -1
        self.bgmPlayer.play()
        
        super.init(size: size)
        
        self.backgroundColor = SKColor.whiteColor()
        
        let player = SKSpriteNode(imageNamed: "player")
        
        player.position = CGPoint(x: player.size.width/2, y: size.height/2)
        
        self.addChild(player)
        
        let actionAddMonster = SKAction.runBlock { () -> Void in
            self.addMonster()
        }
        
        let actionWaitNextMonster = SKAction.waitForDuration(1)
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([actionAddMonster, actionWaitNextMonster])))
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeToResultSceneWithWon(won: Bool) {
        self.bgmPlayer.stop()
        let resultScene = ResultScene(size: self.size, won: won)
        let reveal = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 1)
        self.scene?.view?.presentScene(resultScene, transition: reveal)
    }

    func addMonster() {
        let monster = SKSpriteNode(imageNamed: "monster")
        
        let winSize = self.size
        let minY = monster.size.height/2
        let maxY = winSize.height - monster.size.height/2
        let rangeY = maxY - minY
        let actualY = (random() % Int(rangeY)) + Int(minY)
        
        monster.position = CGPoint(x: winSize.width + monster.size.width/2, y: CGFloat(actualY))
        self.addChild(monster)
        
        let minDuration = 2.0
        let maxDuration = 4.0
        let rangeDuration = maxDuration - minDuration
        let actualDuration = (random() % Int(rangeDuration)) + Int(minDuration)
        
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: CGFloat(actualY)), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.runBlock { () -> Void in
            monster.removeFromParent()
            self.monsters.removeObject(monster)
            //show lose scene
            self.changeToResultSceneWithWon(false)
        }
        
        let sequenceAction = SKAction.sequence([actionMove, actionMoveDone])
        monster.runAction(sequenceAction)
        
        self.monsters.addObject(monster)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let winSize = self.size
            let projectile = SKSpriteNode(imageNamed: "projectile")
            projectile.position = CGPoint(x: projectile.size.width/2, y: winSize.height/2)
            
            let location = touch.locationInNode(self)
            let offset = CGPoint(x: location.x - projectile.position.x, y: location.y - projectile.position.y)
            
            if offset.x <= 0 {
                return
            }
            self.addChild(projectile)
            
            let realX = winSize.width + projectile.size.width/2
            let ratio = offset.y/offset.x
            let realY = realX * ratio + projectile.position.y
            let realDest = CGPoint(x: realX, y: realY)
            
            let offRealX = realX - projectile.position.x
            let offRealY = realY - projectile.position.y
            let length = sqrtf(Float((offRealX * offRealX) + (offRealY * offRealY)))
            let velocity = self.size.width/1
            let realMoveDuration = length / Float(velocity)
            
            let moveAction = SKAction.moveTo(realDest, duration: NSTimeInterval(realMoveDuration))
            let projectileCastAction = SKAction.group([moveAction, self.projectileSoundEffectAction])
            projectile.runAction(projectileCastAction, completion: { () -> Void in
                projectile.removeFromParent()
                self.projectiles.removeObject(projectile)
            })
            
            self.projectiles.addObject(projectile)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        for projectile in self.projectiles {
            for monster in self.monsters {
                if CGRectIntersectsRect(projectile.frame, monster.frame) {
                    self.monsters.removeObject(monster)
                    monster.removeFromParent()
                    self.projectiles.removeObject(projectile)
                    projectile.removeFromParent()
                    
                    self.monstersDestroyed++
                    if self.monstersDestroyed >= 05 {
                        //show win scene
                        self.changeToResultSceneWithWon(true)
                    }
                }
            }
        }
    }
}
