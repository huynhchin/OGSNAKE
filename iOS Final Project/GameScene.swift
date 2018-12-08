//
//  GameScene.swift
//  iOS Final Project
//  This file initalizes the game OGSNAKE 🐍. It creates a loading screen with a title, a best score label, and the play game button. If the user clicks on the play button, then this file will start the game and will create the starting game logic, the in-game view with a new game board, and add swipe gestures for the game.
//  CPSC 315, Fall 2018
//  iOS Final Project
//  No sources to cite
//
//  Created by Chin K. Huynh and Pierce Fleming on 11/25/18.
//  Copyright © 2018 Chin K. Huynh. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //setting up variables
    var gameTitle: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKLabelNode!
    var game: GameManager!
    var currentScore: SKLabelNode!
    var playerPositions: [(Int, Int)] = []
    var gameBackground: SKShapeNode!
    var gameBoard: [(node: SKShapeNode, x: Int, y: Int)] = []
    var scorePos: CGPoint?
    
    override func didMove(to view: SKView) {
        //once the game view is loaded, set up the initial menu
        initializeMenu()
        //Set the game variable to a new GameManager object
        game = GameManager(scene: self)
        //initial the game view
        initializeGameView()
        
        //Add swipe gestures
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
        let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
    //Create functions that are called when the user enters a swipe gesture
    @objc func swipeR() {
        game.checkingSwipe(ID: 3)
    }
    @objc func swipeL() {
        game.checkingSwipe(ID: 1)
    }
    @objc func swipeU() {
        game.checkingSwipe(ID: 2)
    }
    @objc func swipeD() {
        game.checkingSwipe(ID: 4)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        game.update(time: currentTime)
    }
    
    //this function create the menu for when the game first loaded
    func initializeMenu() {
        //Create game title
        gameTitle = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameTitle.zPosition = 1
        gameTitle.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        gameTitle.fontSize = 60
        gameTitle.text = "OGSNAKE 🐍"
        gameTitle.fontColor = SKColor.red
        self.addChild(gameTitle)
        //Create best score label
        bestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameTitle.position.y - 50)
        bestScore.fontSize = 40
        bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
        bestScore.fontColor = SKColor.white
        self.addChild(bestScore)
        //Create play button
        playButton = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        playButton.name = "playButton"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fontSize = 60
        playButton.text = "Play!"
        playButton.fontColor = SKColor.cyan
        self.addChild(playButton)
    }
    
    //this function starts the game if the user clicked on the play button, the function checks that the node name is playButton and start game
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "playButton" {
                    startGame()
                }
            }
        }
    }
    
    //the starting game logic
    func startGame() {
        print("start game")
        gameTitle.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
            self.gameTitle.isHidden = true
        }
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.4)) {
            self.gameBackground.setScale(0)
            self.currentScore.setScale(0)
            self.gameBackground.isHidden = false
            self.currentScore.isHidden = false
            self.gameBackground.run(SKAction.scale(to: 1, duration: 0.4))
            self.currentScore.run(SKAction.scale(to: 1, duration: 0.4))
            self.game.initGame()
        }
    }
    
    //initialize the game view, this function creates the view for player to see when player is playing the game
    func initializeGameView() {
        currentScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        currentScore.fontSize = 40
        currentScore.isHidden = true
        currentScore.text = "Score: 0"
        currentScore.fontColor = SKColor.white
        self.addChild(currentScore)
        let width = frame.size.width - 200
        let height = frame.size.height - 300
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBackground = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBackground.fillColor = SKColor.darkGray
        gameBackground.zPosition = 2
        gameBackground.isHidden = true
        self.addChild(gameBackground)
        createGameBoard(width: Int(width), height: Int(height))
    }
    
    //this function creates the game board
    func createGameBoard(width: Int, height: Int) {
        let cellWidth: CGFloat = 27.5
        let numRows = 38
        let numCols = 20
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2)
        //loop through rows and columns, create cells
        for i in 0...numRows - 1 {
            for j in 0...numCols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = SKColor.black
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                //add to array of cells -- then add to game board
                gameBoard.append((node: cellNode, x: i, y: j))
                gameBackground.addChild(cellNode)
                //iterate x
                x += cellWidth
            }
            //reset x, iterate y
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
    }
}
