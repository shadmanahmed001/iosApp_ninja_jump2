//
//  GameScene.swift
//  Ninja Jump
//
//  Created by Marcus Sakoda on 3/10/17.
//  Copyright © 2017 Marcus Sakoda. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let Ghost : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
let backgroundmusic = SKAction.repeatForever(SKAction.playSoundFileNamed("Godzilla_Unleashed_-_Jet_Jaguar.m4a", waitForCompletion: true))
    
    var Ground = SKSpriteNode()
    var Ghost = SKSpriteNode()
    
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    let scoreLbl = SKLabelNode()
    var died = Bool()
    var restartBTN = SKSpriteNode()
    

    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    
    private var currentCoinDropSpawnTime : TimeInterval = 0
    private var CoinDropSpawnRate : TimeInterval = 0.2
    private let random = GKARC4RandomSource()
    
    func spawnCoindrop() {
        let CoinDrop = SKSpriteNode(imageNamed: "bill")
        CoinDrop.size = CGSize(width: 60, height: 60)
        CoinDrop.position = CGPoint(x: 200, y:  300)
        CoinDrop.zPosition = 2
        
        CoinDrop.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 20))
        
        let randomPosition = abs(CGFloat(random.nextInt()).truncatingRemainder(dividingBy: size.width))
        CoinDrop.position = CGPoint(x: randomPosition, y: size.height)
        
        self.addChild(CoinDrop)
    }
    
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            //            background.anchorPoint = CGPoint.zero
            let z = CGFloat(i) * self.frame.width
            background.position = CGPoint(x: z, y: 0)
            background.name = "background"
            //            background.size = (self.view?.bounds.size)!
            
            //            background.size = CGSize(width:self.scene!.size.width/2, height:self.scene!.size.height)
            background.size = CGSize(width:750, height:self.scene!.size.height)
            self.addChild(background)
            
            //                print("yeeeee")
            //            }
            //            else{
            //                print("naaaaay")
            //            }
            
        }

        


        
        
        print("self view bounds size\(self.view!.bounds.size)")
        scoreLbl.position = CGPoint(x: 0, y: 500)
        scoreLbl.text = "\(score)"
        scoreLbl.fontSize = 50
        scoreLbl.zPosition = 5
        scoreLbl.fontName = "04b_19"
        self.addChild(scoreLbl)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.75)
        Ground.position = CGPoint(x: 0, y: -330)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        
        Ghost = SKSpriteNode(imageNamed: "icon")
        Ghost.size = CGSize(width: 80, height: 80)
        Ghost.position = CGPoint(x: 0, y: 200)
        
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height/2)
        Ghost.physicsBody?.categoryBitMask = PhysicsCategory.Ghost
        Ghost.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.wall
        Ghost.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.wall | PhysicsCategory.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.isDynamic = true
        
        Ghost.zPosition = 2
        
        
        
        self.addChild(Ghost)
        
    }
    
    override func didMove(to view: SKView) {
        self.run(backgroundmusic)
        
        createScene()
        
    }
    
    func createBTN() {
        restartBTN = SKSpriteNode(imageNamed: "RestartBtn")
        restartBTN.size = CGSize(width: 200, height: 100)
        //        restartBTN.setScale(100)
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 6
        self.addChild(restartBTN)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Ghost{
            score += 1
            if score % 2 == 0{
                spawnCoindrop()
                print("Coin should drop")
            }
            scoreLbl.text = "\(score)"
            firstBody.node?.removeFromParent()
            
        }
        else if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Score{
            score += 1
            if score % 2 == 0{
                spawnCoindrop()
                print("Coin should drop")
            }
            
            
            scoreLbl.text = "\(score)"
            secondBody.node?.removeFromParent()
        }
            
        else if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.wall || firstBody.categoryBitMask == PhysicsCategory.wall && secondBody.categoryBitMask == PhysicsCategory.Ghost {
            
            enumerateChildNodes(withName: "WallPair", using: { (node, error) in
                node.speed = 0
                self.removeAllActions()
            })
            if died == false{
                died = true
                createBTN()
            }
        }
                        
            
        else if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Ghost {
            
            enumerateChildNodes(withName: "WallPair", using: { (node, error) in
                node.speed = 0
                self.removeAllActions()
            })
            if died == false{
                died = true
                createBTN()
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {
            gameStarted = true
            Ghost.physicsBody?.affectedByGravity = true
            let spawn = SKAction.run({
                ()
                
                self.createWalls()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + 20)
            let movePipes = SKAction.moveBy(x: -distance - 50, y: 0.0, duration: TimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
        }
        else {
            if died == true {
                createBTN()
            }
            else {
                Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 100))
            }
            
            
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            if died == true {
                if restartBTN.contains(location){
                    restartScene()
                }
                
            }
        }
    }
    
    func createWalls(){
        let scoreNode = SKSpriteNode(imageNamed: "Coin")
        
        scoreNode.size = CGSize(width: 50, height:50)
        scoreNode.position = CGPoint(x: self.frame.width / 2, y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        scoreNode.color = SKColor.white
        
        wallPair = SKNode()
        wallPair.name = "WallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: 400, y: 550)
        btmWall.position = CGPoint(x: 400, y: -350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -100, max: 200)
        print("random is \(randomPosition)")
        
        wallPair.position.y = wallPair.position.y + randomPosition
        print("wallpair position is \(wallPair.position.y)")
        
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
        
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        if gameStarted == true{
            if died == false{
                enumerateChildNodes(withName: "background", using: { (node, error) in
                    let background = node as! SKSpriteNode
                    let d = CGFloat(background.position.x-50)
                    let v = CGFloat(background.position.y)
                    background.position = CGPoint(x: d, y: v)
                    //                    print("bg image size is \(background.size)")
                    //                    print("scene frame here \(self.scene!.frame)")
                    //                    print("bg position before regenration \(background.position)")
                    
                    if background.position.x <= -background.size.width {
                        //                        print("reached last fucntion")
                        //                        print("bg position x before regeneration is \(background.position.x)")
                        //                        print("bg size wisth before regeneraion is \(background.size.width)")
                        
                        
                        
                        background.position = CGPoint(x:background.position.x + background.size.width*2, y:background.position.y)
                        //                        print("bg position after regenration \(background.position)")
                        
                    }
                })
            }
        }
    }
}
