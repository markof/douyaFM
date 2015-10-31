//
//  DWChannleSelector.h
//  WindowTest
//
//  Created by markof on 13-8-11.
//  Copyright (c) 2013年 张磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "CDoubanFMAPI.h"

@interface DWChannleSelector : NSView
{
    NSTextField *middleChannelHolder;
    NSInteger channelIndex;
    BOOL moveIndex;
    @private CGPoint windowsPos;
}

@property(readwrite) NSArray *selection;
@property(readonly) NSNumber *currentindex;
@property(readwrite) NSNumber* isPlaying;

@end
