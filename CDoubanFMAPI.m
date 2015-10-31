//
//  CDoubanFMAPI.m
//  DouyaFM
//
//  Created by markof on 15/6/17.
//  Copyright (c) 2015年 markof. All rights reserved.
//
//  未调的BUG：
//  2. 歌曲History系统不能工作，需要调试。

#import <Foundation/Foundation.h>
#import "CDoubanFMAPI.h"

#define MAX_SONGHISTORYLIST 20
#define DOUBAN_RESULT_ERROR [NSNumber numberWithInt:0]
#define DOUBAN_RESULT_MARK @"r"
#define DOUBAN_REQUEST_NEWSONG @"n"
#define DOUBAN_REQUEST_MORESONG @"p"


//----------------------------------------------------------------------------
@implementation CChannel
@end

@implementation CUserInfo
@end

@implementation CSong
@end

@implementation CPlayHistoryItem
@end

//----------------------------------------------------------------------------
@implementation CDoubanFMAPI

//
enum RequestType {RequestChannel ,RequestSong ,RequestMarkSong ,RequestLogin};

//
-(BOOL)Login:(NSString *)UserName Password:(NSString *)Password
{
    NSDictionary * loginStatus = [self RequestData:RequestLogin UserName:UserName Password:Password];
    
    if (![loginStatus[DOUBAN_RESULT_MARK] isEqual:DOUBAN_RESULT_ERROR])
    {
        self->userinfo.islogin = false;
        self->userinfo.err = loginStatus[@"err"];
        return false;
    }
    
    self->userinfo = [[CUserInfo alloc]init];
    self->userinfo.islogin = true;
    self->userinfo.user_id = loginStatus[@"user_id"];
    self->userinfo.email = loginStatus[@"email"];
    self->userinfo.expire = loginStatus[@"expire"];
    self->userinfo.token = loginStatus[@"token"];
    self->userinfo.user_name = loginStatus[@"user_name"];
    self->userinfo.r = loginStatus[@"r"];
    self->userinfo.err = loginStatus[@"err"];
    
    return true;
}

//
-(BOOL)isLogined
{
    if (self->userinfo.islogin)
    {
        return true;
    }
    else
    {
        return false;
    }
}

//
-(NSArray*) FetchChannels
{
    NSDictionary *ChannelData = [self RequestData:RequestChannel];
    NSMutableArray *Channels = [[NSMutableArray alloc]init];
    NSArray* orgChannels = ChannelData[@"channels"];
    
    if (Channels != nil)
    {
        //返回的数据是channel的集合，所有数据在“channel”下。需要先得到channel集合后才能对每个channel进行处理。
        for (NSInteger index=0; index < orgChannels.count; index++)
        {
            NSDictionary * orgChannelItem = orgChannels[index];
            CChannel *channelItem = [[CChannel alloc] init];
            channelItem.name = orgChannelItem[@"name"];
            channelItem.seq_id = orgChannelItem[@"seq_id"];
            channelItem.addr_en = orgChannelItem[@"addr_en"];
            channelItem.channel_id = orgChannelItem[@"channel_id"];
            channelItem.name_en = orgChannelItem[@"name_en"];
            [Channels addObject: channelItem];
        }
    }
    
    return Channels;
}

//
-(NSArray*) FetchSongs:(CChannel *)channel
{
    NSDictionary *SongData = [self RequestData:RequestSong Channel:channel];
    if (![SongData[DOUBAN_RESULT_MARK] isEqual:DOUBAN_RESULT_ERROR])
    {
        return NULL;
    }
    
    NSMutableArray *Songs = [[NSMutableArray alloc]init];
    NSArray * orgSong = SongData[@"song"];
    
    if (orgSong != nil)
    {
        //返回的数据是channel的集合，所有数据在“channel”下。需要先得到channel集合后才能对每个channel进行处理。
        for (NSInteger index=0; index < orgSong.count; index++)
        {
            NSDictionary * orgSongItem = orgSong[index];
            CSong *SongItem = [[CSong alloc] init];
            SongItem.album = orgSongItem[@"album"];
            SongItem.picture = orgSongItem[@"picture"];
            SongItem.ssid = orgSongItem[@"ssid"];
            SongItem.artist = orgSongItem[@"artist"];
            SongItem.url = orgSongItem[@"url"];
            SongItem.company = orgSongItem[@"company"];
            SongItem.title = orgSongItem[@"title"];
            SongItem.rating_avg = orgSongItem[@"rating_avg"];
            SongItem.length = orgSongItem[@"length"];
            SongItem.subtype = orgSongItem[@"subtype"];
            SongItem.public_time = orgSongItem[@"public_time"];
            SongItem.sid = orgSongItem[@"sid"];
            SongItem.aid = orgSongItem[@"aid"];
            SongItem.kbps = orgSongItem[@"kbps"];
            SongItem.albumtitle = orgSongItem[@"albumtitle"];
            SongItem.like = orgSongItem[@"like"];
            [Songs addObject: SongItem];
        }
    }
    return Songs;
}

//
-(NSDictionary*) RequestData:(enum RequestType)type
{
    if(type != RequestChannel)
    {
        return NULL;
    }
    
    //这里构造一个Post的基本内容，包括参数和url
    NSString * httpBody = @"";
    NSString * url = [self GetUrlByRequestType:type];
    
    //获取发送post后获取得到的数据，从中提取出需要的channels数据。
    NSData * returnData = [self HTTPRequest:url HTTPBody:httpBody];
    
    //把返回的数据进行序列化，以便得到一个可以获取内容的NSDictionary
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    
    //返回所有的Channel的内容
    return jsonObject;
}

//
-(NSDictionary*) RequestData:(enum RequestType)type UserName:(NSString*)username Password:(NSString*)password
{
    if (type != RequestLogin)
    {
        return NULL;
    }
    
    NSString * httpBody = [NSString stringWithFormat:@"app_name=radio_desktop_win&version=100&email=%@&password=%@",username,password];
    NSString * url = [self GetUrlByRequestType:type];
    
    NSData * returnData = [self HTTPRequest:url HTTPBody:httpBody];
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    
    return jsonObject;
}

//
//##ERROR 这里需要填入频道
-(NSDictionary *) RequestData:(enum RequestType)type Song:(CSong*)song SongMark:(enum SongMark)songmark Channel:(CChannel*)channel
{
    if (type!= RequestMarkSong)
    {
        return NULL;
    }
    
    NSString *httpBody = @"";
    
    if (self->userinfo.islogin)
    {
        
        httpBody =[NSString stringWithFormat:@"app_name=radio_desktop_win&version=100&user_id=%@&expire=%@&token=%@&sid=%@&h=%@&type=%@&channel=%@",
            self->userinfo.user_id,
            self->userinfo.expire,
            self->userinfo.token,
            song.sid,
            [self GetSongHistoryMarkString],
            [self GetSongMarker:songmark],
            channel.channel_id];
    }
    
    NSString * url = [self GetUrlByRequestType:type];
    
    NSData * returnData = [self HTTPRequest:url HTTPBody:httpBody];
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    
    return jsonObject;
}

//
-(NSDictionary*) RequestData:(enum RequestType)type Channel:(CChannel*)channel
{
    if (type!= RequestSong)
    {
        return NULL;
    }
    
    //
    NSString* httpBody = [NSString stringWithFormat:@"app_name=radio_desktop_win&version=100&channel=%@&type=%@",
                channel.channel_id, DOUBAN_REQUEST_NEWSONG];
    
    if (self->userinfo.islogin)
    {
        httpBody =[NSString stringWithFormat:@"app_name=radio_desktop_win&version=100&user_id=%@&expire=%@&token=%@&channel=%@&type=%@",
            self->userinfo.user_id,
            self->userinfo.expire,
            self->userinfo.token ,
            channel.channel_id,
             DOUBAN_REQUEST_NEWSONG];
    }
    
    httpBody = [NSString stringWithFormat:@"%@&h=%@",httpBody,[self GetSongHistoryMarkString]];

    NSString * url = [self GetUrlByRequestType:type];
    
    NSData * returnData = [self HTTPRequest:url HTTPBody:httpBody];
    
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
    
    return jsonObject;
}

//
-(NSData*)HTTPRequest:(NSString*)url HTTPBody:(NSString*)httpbody
{
    //这里构造一个基本的url
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    //设置httpbody
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setHTTPBody:[NSData dataWithBytes:[httpbody UTF8String] length:[httpbody length]]];
    
    //获取返回的数据，并返回
    NSData *returnData = [NSURLConnection sendSynchronousRequest:postRequest returningResponse:nil error:nil];
    
    return returnData;
}

//
-(NSString*) GetUrlByRequestType:(enum RequestType)requestType
{
    switch (requestType) {
        case RequestChannel:
            return @"http://www.douban.com/j/app/radio/channels";
        case RequestSong:
            return @"http://www.douban.com/j/app/radio/people";
        case RequestLogin:
            return @"http://www.douban.com/j/app/login";
        case RequestMarkSong:
            return @"http://www.douban.com/j/app/radio/people";
        default:
            return @"";
    }
}

//
-(BOOL)AddHistorySong:(CSong*)song SongMark:(enum SongMark)songmark Channel:(CChannel*)channel
{
    if (self->playhistory == nil)
    {
        self->playhistory = [[NSMutableArray alloc]init];
    }
    
    CPlayHistoryItem * playItem = [[CPlayHistoryItem alloc]init];
    
    playItem.song = song;
    playItem.songmark = songmark;
    
    if (self->playhistory.count >= MAX_SONGHISTORYLIST)
    {
        [self RequestData:RequestMarkSong Song:song SongMark:songmark Channel:channel];
        [self ClearSongHistory];
    }
    
    [self->playhistory addObject:playItem];
    
    return false;
}

//
-(void)ClearSongHistory
{
    [self->playhistory removeAllObjects];
}

//
-(NSString*)GetSongHistoryMarkString
{
    NSString * SongHistoryMark =@"";
    
    if (self->playhistory.count == 0)
    {
        return @"";
    }
    
    for (NSInteger index=0; index<self->playhistory.count; index++)
    {
        CPlayHistoryItem* SongHistoryItem = self->playhistory[index];
        SongHistoryMark = [NSString stringWithFormat:@"%@%@%@:%@",
            SongHistoryMark,
            @"|" ,
            SongHistoryItem.song.sid ,
            [self GetSongMarker:SongHistoryItem.songmark]];
    }
    [self ClearSongHistory];
    
    return SongHistoryMark;
}

//
-(BOOL) RateSong:(CSong *)song Channel:(CChannel*)channel
{
    if (!self->userinfo.islogin)
    {
        return false;
    }
    
    NSDictionary * MarkResult = [self RequestData:RequestMarkSong Song:song SongMark:SongMarkRate Channel:channel];
    
    if (![MarkResult[DOUBAN_RESULT_MARK] isEqual:DOUBAN_RESULT_ERROR])
    {
        return false;
    }
    return true;
}

//
-(BOOL) UnrateSong:(CSong *)song Channel:(CChannel*)channel
{
    if (!self->userinfo.islogin)
    {
        return false;
    }
    
    NSDictionary * MarkResult = [self RequestData:RequestMarkSong Song:song SongMark:SongMarkUnrate Channel:channel];
    if (![MarkResult[DOUBAN_RESULT_MARK] isEqual:DOUBAN_RESULT_ERROR])
    {
        return false;
    }
    return true;
}

//
-(NSString*)GetSongMarker:(enum SongMark)songmark
{
    switch (songmark)
    {
        case SongMarkBye:
            return @"b";
        case SongMarkSkip:
            return @"s";
        case SongMarkUnrate:
            return @"u";
        case SongMarkRate:
            return @"r";
    }
}

@end