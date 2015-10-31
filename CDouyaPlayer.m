//
//  CDouyaPlayer.m
//  DouyaFM
//
//  Created by markof on 15/6/21.
//  Copyright (c) 2015年 markof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDouyaPlayer.h"

#define FAVORATE_CHANNEL_ID @"-3"
#define FAVORATE_CHANNEL_NAME_CN @"红心兆赫"
#define INITIAL_CHANNEL_INDEX 1


@implementation CDouyaPlayer

-(CDouyaPlayer*)init
{
    self = [super init];
    
    self->DoubanFMAPI = [[CDoubanFMAPI alloc]init];
    self->Player = [[AVPlayer alloc]init];
    self->ChannelList = [[NSMutableArray alloc]init];
    self->PlayList = [[NSMutableArray alloc]init];
    
    if (![self InitChannelList]){return nil;}
    if (![self InitPlayList:self->ChannelList[INITIAL_CHANNEL_INDEX]]){return nil;}
    
    [self setValue:self->ChannelList[INITIAL_CHANNEL_INDEX] forKey:@"currentchannel"];
    
    //self->_currentchannel = self->ChannelList[INITIAL_CHANNEL_INDEX];
    
    return self;
}

-(BOOL) InitChannelList
{
    NSArray * SrcChannels = [self->DoubanFMAPI FetchChannels];
    
    if (SrcChannels == nil)
    {
        return false;
    }
    
    CChannel * FavorateChannel = [[CChannel alloc]init];
    
    FavorateChannel.channel_id = FAVORATE_CHANNEL_ID;
    FavorateChannel.name = FAVORATE_CHANNEL_NAME_CN;
    
    [self->ChannelList addObject:FavorateChannel];
    [self->ChannelList addObjectsFromArray:SrcChannels];
    
    self->_channels = self->ChannelList;
    
    return true;
}

-(BOOL) InitPlayList: (CChannel*) channel
{
    NSArray *SrcSongs = [self->DoubanFMAPI FetchSongs:channel];
    
    if (SrcSongs == nil)
    {
        return false;
    }
    
    [self->PlayList removeAllObjects];
    [self->PlayList addObjectsFromArray:SrcSongs];
    
    return true;
}

-(BOOL)Login:(NSString *)username Password:(NSString *)password
{
    if ([self->DoubanFMAPI Login:username Password:password])
    {
        self->_islogined = true;
        return true;
    }
    
    return false;
}

//get next song in playlist
-(CSong*) GetNextSong
{
    if (self->PlayList.count == 0)
    {
        return nil;
    }
    
    if (self->PlayList.count == 1)
    {
        [self->PlayList addObjectsFromArray:[self->DoubanFMAPI FetchSongs:self.currentchannel]];
    }
    
    CSong* song = self->PlayList[0];
    [self->PlayList removeObject:song];
    
    return song;
}

-(BOOL) ChangeChannel:(CChannel *)channel
{
    [self setValue:channel forKey:@"currentchannel"];
    
    if (![self InitPlayList:channel]){return false;}
    
    return [self Play];
}

// play the top song in PlayList.
-(BOOL) Play
{
    //判断当前播放器中是否存在，如果存在，需要预先释放当前播放器。
    if (self->Player == nil)
    {
        return false;
    }
    
    CSong * song = self->PlayList[0];
    [self setValue:song forKey:@"currentsong"];
    
    NSURL * songurl = [NSURL URLWithString:song.url];
    AVPlayerItem *songItem = [[AVPlayerItem alloc] initWithURL:songurl];
    [self->Player replaceCurrentItemWithPlayerItem:songItem];
    [self->Player removeTimeObserver:self->ObserverObject];
    [self->Player play];
    
    CMTime interval = CMTimeMake(1, 1);
    
    __weak typeof(self) weakSelf = self;
    
    self->ObserverObject=[self->Player addPeriodicTimeObserverForInterval:interval queue:nil
    usingBlock:^(CMTime time)
    {
        NSNumber * currentPlayingTime = [NSNumber numberWithLong:self->Player.currentTime.value / self->Player.currentTime.timescale];
        NSNumber * totlePlayingTime = [NSNumber numberWithLong:self->Player.currentItem.duration.value / self->Player.currentItem.duration.timescale];
        
        [weakSelf setValue:currentPlayingTime forKey:@"currenttime"];
        [weakSelf setValue:totlePlayingTime forKey:@"duration"];
        
        if ( currentPlayingTime >= totlePlayingTime )
        {
            [weakSelf Skip];
        }
    }];
    
    return true;
}

-(BOOL)Skip
{
    [self->DoubanFMAPI AddHistorySong:self.currentsong SongMark:SongMarkSkip Channel:self->_currentchannel];
    self->_currentsong = [self GetNextSong];
    
    return [self Play];
}

-(BOOL)RateSong:(CSong *)song
{
    if (self->DoubanFMAPI == nil)
    {
        return false;
    }
    
    return [self->DoubanFMAPI RateSong:song Channel:self->_currentchannel ];
}

-(BOOL)UnrateSong:(CSong *)song
{
    if (self->DoubanFMAPI == nil)
    {
        return false;
    }
    
    return [self->DoubanFMAPI UnrateSong:song Channel:self->_currentchannel];
}

-(BOOL)ByeSong:(CSong *)song
{
    if (self->DoubanFMAPI == nil)
    {
        return false;
    }

    [self->DoubanFMAPI AddHistorySong:self.currentsong SongMark:SongMarkBye Channel:self->_currentchannel];
    self->_currentsong = [self GetNextSong];
    
    return [self Play];
}

-(BOOL)Pause
{
    //判断当前播放器中是否存在，如果存在，需要预先释放当前播放器。
    if (self->Player != nil)
    {
        [self->Player pause];
        
        if (self->Player.status == AVPlayerStatusReadyToPlay)
        {
            return YES;
        }
        return NO;
    }
    else
    {
        return NO;
    }
}

-(BOOL)Continue
{
    //判断当前播放器中是否存在，如果存在，需要预先释放当前播放器。
    if (self->Player != nil)
    {
        [self->Player play];
        
        if (self->Player.status == AVPlayerStatusReadyToPlay)
        {
            return YES;
        }
        return NO;
    }
    else
    {
        return NO;
    }
}


@end