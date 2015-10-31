//
//  DWProgressBar.m
//  WindowTest
//
//  Created by markof on 13-8-11.
//  Copyright (c) 2013年 张磊. All rights reserved.
//

#import "DWProgressBar.h"

@implementation DWProgressBar

-(DWProgressBar*)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    self.lenght = 100;
    self.current = 0;
    
    [self addObserver:self forKeyPath:@"current" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)  context:nil];
    return self;
}

-(void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *progressBarBackground = [NSBezierPath bezierPath];
    [[NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.1 alpha:1.0] set];
    [progressBarBackground setLineWidth:5.0];
    [progressBarBackground setLineCapStyle:NSRoundLineCapStyle];
    [progressBarBackground moveToPoint: NSMakePoint(6,3)];
    [progressBarBackground lineToPoint: NSMakePoint(self.frame.size.width-6,3)];
    [progressBarBackground stroke];
    
    NSInteger totleLength = self.frame.size.width-12;
    NSInteger statusLength=0;
    if (self.lenght)
    {
        statusLength = self.current*totleLength/self.lenght;
    }
    NSBezierPath *progressBarStatus = [NSBezierPath bezierPath];
    [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0] set];
    [progressBarStatus setLineWidth:5.0];
    [progressBarStatus setLineCapStyle:NSRoundLineCapStyle];
    [progressBarStatus moveToPoint: [self convertPoint:NSMakePoint(6,3) toView:self]];
    [progressBarStatus lineToPoint: [self convertPoint:NSMakePoint(6+statusLength,3) toView:self]];
    [progressBarStatus stroke];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsDisplay:YES];
}

@end
