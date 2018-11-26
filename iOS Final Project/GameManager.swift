//
//  GameManager.swift
//  iOS Final Project
//
//  Created by Chin K. Huynh on 11/25/18.
//  Copyright © 2018 Chin K. Huynh. All rights reserved.
//

import SpriteKit

class GameManager {
    
    var scene: GameScene!
    var nextTime: Double?
    var timeSpeed: Double = 0.10
    //0 = dead, 1 = left, 2 = up, 3 = right, 4 = down
    var playerDirection: Int = 4
    var currentScore: Int = 0
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func initGame() {
        //starting player position
        scene.playerPositions.append((20, 10))
        scene.playerPositions.append((19, 10))
        scene.playerPositions.append((18, 10))
        renderChange()
        generateNewPoint()
    }
    
    func generateNewPoint() {
        var randomX = CGFloat(arc4random_uniform(19))
        var randomY = CGFloat(arc4random_uniform(39))
        while contains(a: scene.playerPositions, v: (Int(randomX), Int(randomY))) {
            randomX = CGFloat(arc4random_uniform(19))
            randomY = CGFloat(arc4random_uniform(39))
        }
        scene.scorePos = CGPoint(x: randomX, y: randomY)
    }
    
    func update(time: Double) {
        if nextTime == nil {
            nextTime = time + timeSpeed
        } else {
            if time >= nextTime! {
                nextTime = time + timeSpeed
                updatePlayerPosition()
                checkForScore()
                checkEndGame()
                finishGame()
            }
        }
    }
    
    func updateScore() {
        if currentScore > UserDefaults.standard.integer(forKey: "bestScore") {
            UserDefaults.standard.set(currentScore, forKey: "bestScore")
        }
        currentScore = 0
        scene.currentScore.text = "Score: 0"
        scene.bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
    }
    
    func finishGame() {
        if playerDirection == 0 && scene.playerPositions.count > 0 {
            var hasFinished = true
            let headOfSnake = scene.playerPositions[0]
            for position in scene.playerPositions {
                if headOfSnake != position {
                    hasFinished = false
                }
            }
            if hasFinished {
                print("end game")
                updateScore()
                playerDirection = 4
                //animation has completed
                scene.scorePos = nil
                scene.playerPositions.removeAll()
                renderChange()
                //return to menu
                scene.currentScore.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.currentScore.isHidden = true
                    }
                    scene.gameBackground.run(SKAction.scale(to: 0, duration: 0.4)) {
                        self.scene.gameBackground.isHidden = true
                        self.scene.gameTitle.isHidden = false
                        self.scene.gameTitle.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
                            self.scene.playButton.isHidden = false
                            self.scene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                            self.scene.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameTitle.position.y - 50), duration: 0.3))
                        }
                }
            }
        }
    }
    
    func checkEndGame() {
        if scene.playerPositions.count > 0 {
            var arrayOfPositions = scene.playerPositions
            let headOfSnake = arrayOfPositions[0]
            arrayOfPositions.remove(at: 0)
            if contains(a: arrayOfPositions, v: headOfSnake) {
                playerDirection = 0
            }
        }
    }
    
    func updatePlayerPosition() {
        var xChange = 0
        var yChange = 0
        switch playerDirection {
        case 1:
            //left
            xChange = -1
            yChange = 0
            break
        case 2:
            //up
            xChange = 0
            yChange = -1
            break
        case 3:
            //right
            xChange = 1
            yChange = 0
            break
        case 4:
            //down
            xChange = 0
            yChange = 1
            break
        case 0:
            //dead
            xChange = 0
            yChange = 0
            break
        default:
            break
        }
        if scene.playerPositions.count > 0 {
            var start = scene.playerPositions.count - 1
            while start > 0 {
                scene.playerPositions[start] = scene.playerPositions[start - 1]
                start -= 1
            }
            scene.playerPositions[0] = (scene.playerPositions[0].0 + yChange, scene.playerPositions[0].1 + xChange)
        }
        //allow the snake to loop around the screen
        if scene.playerPositions.count > 0 {
            let x = scene.playerPositions[0].1
            let y = scene.playerPositions[0].0
            if y > 40 {
                scene.playerPositions[0].0 = 0
            } else if y < 0 {
                scene.playerPositions[0].0 = 40
            } else if x > 20 {
                scene.playerPositions[0].1 = 0
            } else if x < 0 {
                scene.playerPositions[0].1 = 20
            }
        }
        renderChange()
    }
    
    func checkForScore() {
        if scene.scorePos != nil {
            let x = scene.playerPositions[0].0
            let y = scene.playerPositions[0].1
            if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                currentScore += 1
                scene.currentScore.text = "Score: \(currentScore)"
                generateNewPoint()
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
                scene.playerPositions.append(scene.playerPositions.last!)
            }
        }
    }
    
    func swipe(ID: Int) {
        if !(ID == 2 && playerDirection == 4) && !(ID == 4 && playerDirection == 2) {
            if !(ID == 1 && playerDirection == 3) && !(ID == 3 && playerDirection == 1) {
                if playerDirection != 0 {
                    playerDirection = ID
                }
            }
        }
    }
    
    func renderChange() {
        for (node, x, y) in scene.gameBoard {
            if contains(a: scene.playerPositions, v: (x,y)) {
                node.fillColor = SKColor.green
            } else {
                node.fillColor = SKColor.clear
                if scene.scorePos != nil {
                    if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
                        node.fillColor = SKColor.red
                    }
                }
            }
        }
    }
    
    func contains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
        let (c1, c2) = v
        for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
        return false
    }
}
