//
//  DWChannleSelector.m
//  WindowTest
//
//  Created by markof on 13-8-11.
//  Copyright (c) 2013年 张磊. All rights reserved.
//

#import "DWChannleSelector.h"
#import "CDoubanFMAPI.h"

@implementation DWChannleSelector

-(DWChannleSelector *)initWithFrame:(NSRect)frame;
{
    self = [super initWithFrame:frame];
    
    middleChannelHolder = [[NSTextField alloc]initWithFrame:NSMakeRect(0, frame.size.height/2-20, frame.size.width, 40)];
    [middleChannelHolder setFont:[NSFont fontWithName:@"Heiti SC" size:40]];
    [middleChannelHolder setTextColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.9]];
    [middleChannelHolder setAlignment:NSCenterTextAlignment];
    [middleChannelHolder setBezeled:NO];
    [middleChannelHolder setBackgroundColor:[NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0.3]];
    [middleChannelHolder setDrawsBackground:YES];
    [middleChannelHolder setEditable:NO];
    [middleChannelHolder setSelectable:NO];
    [middleChannelHolder setAlphaValue:0.0];

    [self addSubview:middleChannelHolder];
    self->channelIndex = 0;
    self->_currentindex = 0;
    self.acceptsTouchEvents = YES;
    return self;
}

- (void)mouseDown:(NSEvent *)event {
    self->windowsPos.x = event.window.frame.origin.x;
    self->windowsPos.y = event.window.frame.origin.y;
}

- (void)mouseUp:(NSEvent *)event {
    if (event.window.frame.origin.x == self->windowsPos.x && event.window.frame.origin.y == self->windowsPos.y)
    {
        if (self.isPlaying.intValue == 1)
        {
            [self setValue:[NSNumber numberWithInt:0] forKey:@"isPlaying"];
        }
        else
        {
            [self setValue:[NSNumber numberWithInt:1]  forKey:@"isPlaying"];
        }
    }
}

-(void)beginGestureWithEvent:(NSEvent *)event
{
    if (self.selection != nil)
    {
        [self->middleChannelHolder setAlphaValue:1.0];
        self->moveIndex = YES;
    }
}

-(void)scrollWheel:(NSEvent *)event
{
    
    if (event.deltaY==0)
    {
        
    }
    else if (event.deltaY >0)
    {
        if (self->channelIndex<self.selection.count-1)
        {
            self->channelIndex ++;
        }
    }
    else
    {
        if (self->channelIndex>0)
        {
            self->channelIndex--;
        }
    }
    
    CChannel *tempchannel = self.selection[self->channelIndex];
    [self->middleChannelHolder setStringValue:tempchannel.name];

}

-(void)endGestureWithEvent:(NSEvent *)event
{
    [self->middleChannelHolder setAlphaValue:0.0];
    self->moveIndex = NO;
    [self setValue:[NSNumber numberWithLong:self->channelIndex] forKey:@"currentindex"];
}

@end
