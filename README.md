# DiveIntoSpriteKit
A basic game based on the Project 1 from [Dive Into SpriteKit book by Paul Hudson](https://www.hackingwithswift.com/store/dive-into-spritekit).

## Issues

### Timer
The instructions in the book guide you to use the `Timer`. If you do so, you have to also use `.invalidate()` on the timer or you will have **performance degradation**. See [Performance issue with “Dive Into SpriteKit” example code](https://stackoverflow.com/questions/56794968/performance-issue-with-dive-into-spritekit-example-code)

### Physics body shape
SpriteKit seems to have an issue making an alpha-based outline for physical body for junk sattelite. As a result collision detection is off. You can see the physics bodies by switching `view.showsPhysics = true`.

We made a new version of the graphical asset to see if it is related to the way it's done, but it seems unrelated. No we are asking for help: [SpriteKit: physics body “alpha” shape issues](https://stackoverflow.com/questions/56817220/skspritenode-physics-body-peculiar-shape-issue)

### Memory leak
Fixing the timer is solving main performance drag, but the app is still gobbling memory over time. We are looking for a solution.


## Improvements

### Bitmask categories
The book is not going into details about the bitmask nature of categoryBitMask. Working in parallel on two version with my son we both got confused at some point. Learning a bit more helped: bitmasks are not just numbers, but a neat way to use individual bits as markers and run checks. Each category is one of 32 bits set to 1. You can use `0x1 << 1, 0x1 << 2, 0x1 << 3` to set the bits and `|` to merge categories for contactTestBitMask and collisionBitMask. 

See [How to set up SceneKit collision detection](https://stackoverflow.com/questions/27372138/how-to-set-up-scenekit-collision-detection/27389834#27389834).

### Explosion direction
To make the gave over the moment a bit nicer, we set the velocity of the node player collided with to the explosion particle effect.

### Spinning
When we allowed a player to survive collisions spinning became a problem. `player.physicsBody?.allowsRotation = false` could be a radical way to deal with it. In our case we are trying to make z-axis stabilization work applying torque in the oposite to spinning direction. 

### Top 3
We added the top 3 scores with saving in UserDefaults.

### Scene editor
After watching [Best Practices for Building SpriteKit Games](https://developer.apple.com/videos/play/wwdc2014/608/) we are looking into using Scene editor to define the basic structure. As a first step, we moved space texture and player node to the GameScene.sks.
