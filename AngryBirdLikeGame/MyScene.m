//
//  MyScene.m
//  AngryBirdLikeGame
//
//  Created by kitano on 2014/01/17.
//  Copyright (c) 2014年 kitano. All rights reserved.
//

#import "MyScene.h"

enum
{
    kDragNone,  //初期値
    kDragStart, //Drag開始
    kDragEnd,   //Drag終了
};

@implementation MyScene
{
    SKSpriteNode *ball;
    SKSpriteNode *target;
    int  gameStatus;
    CGPoint startPos;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        self.anchorPoint = CGPointMake(0.5f, 0.5f);
        gameStatus = kDragNone;
        
        SKNode *myWorld = [SKNode node];
        myWorld.name = @"world";
        [self addChild:myWorld];
        
        SKNode *camera = [SKNode node];
        camera.name = @"camera";
        [myWorld addChild:camera];

        //地面
        SKSpriteNode *ground = [[SKSpriteNode alloc] initWithColor:[SKColor brownColor]
                                                              size:CGSizeMake(size.width*10,
                                                                              size.height)];
        ground.position    = CGPointMake(0, -ground.size.height + 30);
        ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground.size];
        ground.physicsBody.dynamic = NO;
        [myWorld addChild:ground];
        
        ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball.png"];
        ball.position = CGPointMake(0, -20);
        ball.name = @"ball";
        ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.size.width/2];
        ball.physicsBody.dynamic = NO;
        [myWorld addChild:ball];
        
        
        int start_x = 600;
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(15,80)];
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        sprite.physicsBody.categoryBitMask = 0x1 << 1;
        sprite.position = CGPointMake(start_x + 100,-90);
        [myWorld addChild:sprite];
        
        sprite = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(15,80)];
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        sprite.physicsBody.categoryBitMask = 0x1 << 1;
        sprite.position = CGPointMake(start_x + 200,-90);
        [myWorld addChild:sprite];
        
        sprite = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(150,15)];
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        sprite.physicsBody.categoryBitMask = 0x1 << 1;
        sprite.position = CGPointMake(start_x + 150,-50);
        [myWorld addChild:sprite];
        
        sprite = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(15,50)];
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        sprite.physicsBody.categoryBitMask = 0x1 << 0;
        sprite.position = CGPointMake(start_x + 120,-20);
        [myWorld addChild:sprite];

        sprite = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(15,50)];
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        sprite.physicsBody.categoryBitMask = 0x1 << 0;
        sprite.position = CGPointMake(start_x + 180,-20);
        [myWorld addChild:sprite];
        
        sprite = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:CGSizeMake(100,15)];
        sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        sprite.position = CGPointMake(start_x + 150,0);
        sprite.physicsBody.categoryBitMask = 0x1 << 0;
        [myWorld addChild:sprite];
        
        
        target = [SKSpriteNode spriteNodeWithColor:[SKColor redColor] size:CGSizeMake(15,15)];
        target.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:target.size];
        target.physicsBody.contactTestBitMask = 0x1 << 0;
        target.position = CGPointMake(start_x + 150,-35);
        [myWorld addChild:target];

        
        self.physicsWorld.contactDelegate = self;

        
    }
    return self;
}

//衝突開始時
- (void)didBeginContact:(SKPhysicsContact *)contact
{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Spark" ofType:@"sks"];
        SKEmitterNode *spark = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        spark.numParticlesToEmit = 50;
        spark.particlePosition = contact.contactPoint;
        [self addChild:spark];
        [target removeFromParent];
}

- (void)didSimulatePhysics
{
    //nameより、cameraノードを取得
    SKNode *camera = [self childNodeWithName: @"//camera"];
    if(gameStatus == kDragEnd && ball.position.x > 0)
        camera.position = CGPointMake(ball.position.x, camera.position.y);
    [self centerOnNode: camera];
}

- (void) centerOnNode: (SKNode *) node
{
    CGPoint cameraPositionInScene = [node.scene convertPoint:node.position fromNode:node.parent];
    node.parent.position = CGPointMake(node.parent.position.x - cameraPositionInScene.x,                                       node.parent.position.y - cameraPositionInScene.y);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];
        if(node != nil && [node.name isEqualToString:@"ball"]) {
            gameStatus = kDragStart;
            startPos = location;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(gameStatus == kDragStart ){
        UITouch *touch = [touches anyObject];
        CGPoint touchPos = [touch locationInNode:self];
        ball.position = touchPos;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(gameStatus == kDragStart ){
        gameStatus = kDragEnd;

        UITouch *touch = [touches anyObject];
        CGPoint endPos = [touch locationInNode:self];

        //x,yの移動距離を算出
        CGPoint diff = CGPointMake(startPos.x - endPos.x, startPos.y - endPos.y);
        
        
        ball.physicsBody.dynamic = YES;
        //yを少し大きく
        [ball.physicsBody applyForce:CGVectorMake(diff.x * 20 , diff.y * 50)];

        SKAction *scaleOut = [SKAction scaleTo:0.5 duration:0.2];
        SKAction *moveUp   = [SKAction moveByX:0   y:-100 duration:0.2];
        SKAction *scale1   = [SKAction group:@[scaleOut,moveUp]];
        SKAction *delay    = [SKAction waitForDuration:1.0];
        SKAction *scaleIn  = [SKAction scaleTo:1 duration:1.0];
        SKAction *moveDown = [SKAction moveByX:0   y:100 duration:1.0];
        SKAction *scale2   = [SKAction group:@[scaleIn,moveDown]];
        SKAction *moveSequence = [SKAction sequence:@[scale1, delay,scale2]];
        [self runAction:moveSequence];

        
    }
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
