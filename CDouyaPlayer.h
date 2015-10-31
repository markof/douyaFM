//
//  CDouyaPlayer.h
//  DouyaFM
//
//  Created by markof on 15/6/21.
//  Copyright (c) 2015年 markof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <CoreMedia/CMTime.h>
#import "CDoubanFMAPI.h"

#ifndef DouyaFM_CDouyaPlayer_h
#define DouyaFM_CDouyaPlayer_h

#endif


@interface CDouyaPlayer : NSObject
{
    
    @private CDoubanFMAPI * DoubanFMAPI;
    @private AVPlayer * Player;
    @private NSMutableArray * ChannelList;
    @private NSMutableArray * PlayList;
    @private id ObserverObject;
}

@property (readonly) BOOL islogined;

@property (readonly) NSArray * channels;
@property (readonly) CChannel * currentchannel;
@property (readonly) CSong * currentsong;
@property (readonly) NSNumber* currenttime;
@property (readonly) NSNumber* duration;

-(BOOL)Play;
-(BOOL)Skip;
-(BOOL)Pause;
-(BOOL)Continue;
-(BOOL)Login:(NSString*)username Password:(NSString *)password;
-(BOOL)ChangeChannel:(CChannel*)channel;
-(BOOL)RateSong:(CSong*)song;
-(BOOL)UnrateSong:(CSong*)song;
-(BOOL)ByeSong:(CSong*)song;

@end
