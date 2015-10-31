//
//  CDoubanFMAPI.h
//  DouyaFM
//
//  Created by markof on 15/6/18.
//  Copyright (c) 2015年 markof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSNetServices.h>
#import <Foundation/NSJSONSerialization.h>

#ifndef DouyaFM_CDoubanFMAPI_h
#define DouyaFM_CDoubanFMAPI_h
#endif


@interface CUserInfo : NSObject
    @property (readwrite) BOOL     islogin;
    @property (readwrite) NSString *user_id;
    @property (readwrite) NSString *err;
    @property (readwrite) NSString *token;
    @property (readwrite) NSString *expire;
    @property (readwrite) NSString *r;
    @property (readwrite) NSString *user_name;
    @property (readwrite) NSString *email;
@end


@interface CChannel :  NSObject
    @property (readwrite) NSString *name;
    @property (readwrite) NSString *seq_id;
    @property (readwrite) NSString *addr_en;
    @property (readwrite) NSString *channel_id;
    @property (readwrite) NSString *name_en;
@end

@interface CSong :  NSObject
    @property (readwrite) NSString *album;
    @property (readwrite) NSString *picture;
    @property (readwrite) NSString *ssid;
    @property (readwrite) NSString *artist;
    @property (readwrite) NSString *url;
    @property (readwrite) NSString *company;
    @property (readwrite) NSString *title;
    @property (readwrite) NSString *rating_avg;
    @property (readwrite) NSString *length;
    @property (readwrite) NSString *subtype;
    @property (readwrite) NSString *public_time;
    @property (readwrite) NSString *sid;
    @property (readwrite) NSString *aid;
    @property (readwrite) NSString *kbps;
    @property (readwrite) NSString *albumtitle;
    @property (readwrite) NSNumber *like;
@end

@interface CPlayHistoryItem : NSObject
    @property (readwrite) CSong *song;
    @property (readwrite) enum SongMark songmark;
@end

//
enum SongMark
{
    SongMarkRate, SongMarkUnrate, SongMarkBye, SongMarkSkip
};

//define a class named CDoubanFMAPI
@interface CDoubanFMAPI : NSObject
{
    @private CUserInfo *userinfo;
    @private NSMutableArray *playhistory;
}

//
-(BOOL)Login:(NSString*)UserName Password:(NSString*)Password;

//
-(BOOL)isLogined;

//
-(NSArray *)FetchChannels;

//
-(NSArray *)FetchSongs:(CChannel*) channel;

//
-(BOOL)RateSong:(CSong*)song Channel:(CChannel*)channel;

//
-(BOOL)UnrateSong:(CSong*) song Channel:(CChannel*)channel;

//
-(BOOL)AddHistorySong:(CSong*)song SongMark:(enum SongMark)songmark Channel:(CChannel*)channel;

@end