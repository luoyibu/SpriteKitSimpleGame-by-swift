//
//  ResultScene.swift
//  SpriteKitSimpleGame
//
//  Created by luoxuan-mac on 14-10-10.
//  Copyright (c) 2014年 luoyibu. All rights reserved.
//

import UIKit
import SpriteKit

class ResultScene: SKScene {
   
    func changeToGameScene() {
        let ms = GameScene.sceneWithSize(self.size)
        let reveal = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 1.0)
        self.scene?.view?.presentScene(ms, transition: reveal)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            let node = self.nodeAtPoint(touchLocation) as SKNode
            if node.name == "retryLabel" {
                self.changeToGameScene()
            }
        }
    }
    
    init(size: CGSize, won: Bool) {
        
        super.init(size: size)
        self.backgroundColor = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let resultLabel = SKLabelNode(fontNamed: "Chalkduster")
        resultLabel.text = won ? "You win!" : "You lose"
        resultLabel.fontSize = 30
        resultLabel.fontColor = SKColor.blackColor()
        resultLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(resultLabel)
        
        let retryLabel = SKLabelNode(fontNamed: "Chalkduster")
        retryLabel.text = "Try again"
        retryLabel.fontSize = 20
        retryLabel.fontColor = SKColor.blueColor()
        retryLabel.position = CGPoint(x: resultLabel.position.x, y: resultLabel.position.y * 0.8)
        retryLabel.name = "retryLabel"
        self.addChild(retryLabel)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
