# DiveIntoSpriteKit
A basic game based on the Project 1 from [Dive Into SpriteKit book by Paul Hudson].(https://www.hackingwithswift.com/store/dive-into-spritekit)

# Changes

## Timer

The instructions in the book guide you to use the Timer. If you do so, you have to also use .invalidate() on the timer or you will get accumulating performance degradation later. See https://stackoverflow.com/questions/56794968/performance-issue-with-dive-into-spritekit-example-code

## categoryBitMask

The book is not going into details about the bitmask nature of categoryBitMask. Working in parallel on two version with my son we both got confused at some point. Learning a bit more about bitmasks helped: they are not just numbers, but a neat way to use bits for markers and, later, comparison. Each category is one of 32 bits set to 1. You can use `0x1 << 1, 0x1 << 2, 0x1 << 3` to set the bits and `|` to merge categories for contactTestBitMask and collisionBitMask. 

## Spinning

When we allowed a player to survive collisions spinning became a problem. `player.physicsBody?.allowsRotation = false` could a radical way to deal with it. In our case we trying to make z-axis stabilization work.

