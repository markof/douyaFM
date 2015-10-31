//
//  AppDelegate.m
//  DouyaFM
//
//  Created by markof on 15/6/17.
//  Copyright (c) 2015年 markof. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSMenuItem *MenuPalyPause;

@end

@implementation AppDelegate

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self->RateButtonImage = [NSImage imageNamed:@"rateSongButton.png"];
    self->UnrateButtonImage = [NSImage imageNamed:@"unratesongbutton.png"];
    [self->RateButtonImage setSize:NSMakeSize(22, 22)];
    [self->UnrateButtonImage setSize:NSMakeSize(22, 22)];
    
    if (![self initUserInterface])
    {

    }
    
    self->player = [[CDouyaPlayer alloc]init];
    if (self->player == nil)
    {
        
    }

    self->channels = self->player.channels;
    self->isPlaying = true;
    channleSelector.selection = self->channels;
    
    [self->player addObserver:self forKeyPath:@"currentsong" options:NSKeyValueObservingOptionNew context:@"songchange"];
    [self->player addObserver:self forKeyPath:@"currentchannel" options:NSKeyValueObservingOptionNew context:@"channelchange"];
    [self->player addObserver:self forKeyPath:@"currenttime" options:NSKeyValueObservingOptionNew context:@"timechange"];
    [self->channleSelector addObserver:self forKeyPath:@"currentindex" options:NSKeyValueObservingOptionNew context:@"channelchange"];
    [self->channleSelector addObserver:self forKeyPath:@"isPlaying" options:NSKeyValueObservingOptionNew context:@"changeplaystatus"];
    
    if (![self->player Play])
    {
        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString : @"currentsong"])
    {
        [self UpdateUIBySong:self->player.currentsong];
    }
    if ([keyPath isEqualToString:@"currenttime"])
    {
        NSString *songTotleTimeMinutes = [NSString stringWithFormat:@"%02d",[self->player.currenttime intValue]/60];
        NSString *songTotleTimeSecond = [NSString stringWithFormat:@"%02d",[self->player.currenttime intValue]%60];
        [self->songCurrentPlayTime setStringValue:[NSString stringWithFormat:@"%@:%@",songTotleTimeMinutes,songTotleTimeSecond]];
        self->progressBar.current = [self->player.currenttime intValue];
    }
    if ([keyPath isEqualToString:@"currentindex"])
    {
        [self channelChange:self->channels[self->channleSelector.currentindex.intValue]];
    }
    
    if ([keyPath isEqualToString:@"isPlaying"])
    {
        if(self->isPlaying == TRUE)
        {
            [self->player Pause];
            self->isPlaying = false;
            [self->playButtonView setHidden:NO];
            [self.MenuPalyPause setTitle:@"播放"];
        }
        else
        {
            [self->player Continue];
            self->isPlaying = true;
            [self->playButtonView setHidden:YES];
            [self.MenuPalyPause setTitle:@"暂停"];
        }
    }
}

//设置Favorite Botton的状态，ON表示可以标记当前歌曲为喜欢，OFF表示可标记当前歌曲为不喜欢。
-(void)SwithRateSongButton:(enum Switch)Switch
{
    switch (Switch) {
        case ON:
            [self->rateSongButton setImage:self->UnrateButtonImage];
            break;
            
        case OFF:
            [self->rateSongButton setImage:self->RateButtonImage];
            break;
    }
}

//根据当前播放歌曲刷新整个界面
-(void)UpdateUIBySong:(CSong*)song
{
    [self->songArtist setStringValue:song.artist];
    [self->songTitle setStringValue:song.title];
    
    NSString *songTotleTimeMinutes = [NSString stringWithFormat:@"%02d",[song.length intValue]/60];
    NSString *songTotleTimeSecond = [NSString stringWithFormat:@"%02d",[song.length intValue]%60];
    
    [self->songTotleTime setStringValue:[NSString stringWithFormat:@"%@:%@",songTotleTimeMinutes,songTotleTimeSecond]];
    [self->songCurrentPlayTime setStringValue:@"00:00"];
    //[self->_window setTitle:[NSString stringWithFormat:@"%@-%@",song.artist,song.title]];
    self->progressBar.lenght = [song.length intValue];
    self->progressBar.current = 0;
    
    NSURL *imageUrl = [NSURL URLWithString:[song.picture stringByReplacingOccurrencesOfString:@"mpic" withString:@"lpic"]];
    NSImage *pictureImage = [[NSImage alloc] initWithContentsOfURL:imageUrl];
    
    [self UpdateAppBackground : pictureImage];
    [self UpdateAppIcon : pictureImage];
    
    if ([song.like isEqual:[NSNumber numberWithInt:1]])
    {
        [self SwithRateSongButton:ON];
    }
    else
    {
        [self SwithRateSongButton:OFF];
    }
}

//构建整个用户界面。
-(BOOL)initUserInterface
{
    NSRect ScreenFrame =  [[NSScreen mainScreen] frame];
    NSInteger x = ScreenFrame.size.width/2 -200;
    NSInteger y = ScreenFrame.size.height/2 - 80;
    
    //初始化窗口大小和位置，初始化窗口标题
    [self->_window setFrame:NSMakeRect(x, y, 400, 260) display:true];
    [self->_window setTitle:@""];
    
    //初始化喜欢按钮
    self->rateSongButton = [[NSButton alloc] initWithFrame:NSMakeRect(255, 36, 22, 22)];
    [rateSongButton setBordered:NO];
    [rateSongButton.cell setHighlightsBy:NSContentsCellMask];
    [rateSongButton setImage:self->RateButtonImage];
    [rateSongButton setAction:@selector(rateSongAction:)];
    
    //初始化播放下一首按钮
    NSButton *playNextButton = [[NSButton alloc] initWithFrame:NSMakeRect(310, 36, 22, 22)];
    [playNextButton setBordered:NO];
    [playNextButton.cell setHighlightsBy:NSContentsCellMask];
    NSImage * PlayNextButtonImage = [NSImage imageNamed:@"playNextButton.png"];
    [PlayNextButtonImage setSize:NSMakeSize(22, 22)];
    [playNextButton setImage:PlayNextButtonImage];
    [playNextButton setTarget:self];
    [playNextButton setAction:@selector(playNextAction:)];
    
    //初始化永不播放歌曲按钮
    NSButton *neverPlayTheSongButton = [[NSButton alloc] initWithFrame:NSMakeRect(365, 36, 22, 20)];
    [neverPlayTheSongButton setBordered:NO];
    [neverPlayTheSongButton.cell setHighlightsBy:NSContentsCellMask];
    NSImage * neverPlayTheSongButtonImage = [NSImage imageNamed:@"neverPlayTheSongButton.png"];
    [neverPlayTheSongButtonImage setSize:NSMakeSize(22, 22)];
    [neverPlayTheSongButton setImage:neverPlayTheSongButtonImage];
    [neverPlayTheSongButton setAction:@selector(byeSongAction:)];
    
    //初始化播放暂停时，显示的播放按钮
    NSImage * PlayButtonImage = [NSImage imageNamed:@"pausebutton.png"];
    self->playButtonView  = [[NSImageView alloc]initWithFrame:NSMakeRect(164, 120, 76, 76)];
    [self->playButtonView setImage:PlayButtonImage];
    [self->playButtonView setHidden:YES];
    
    //初始化歌曲标题lable
    songTitle = [[NSTextField alloc]initWithFrame:NSMakeRect(10, 32, 230, 26)];
    [songTitle setFont:[NSFont fontWithName:@"Heiti SC" size:22]];
    [songTitle setTextColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [songTitle setStringValue:@""];
    [songTitle setBezeled:NO];
    [songTitle setDrawsBackground:NO];
    [songTitle setEditable:NO];
    [songTitle setSelectable:NO];
    [songTitle.cell setLineBreakMode:NSLineBreakByTruncatingTail];
    
    //初始化作者标题lable
    songArtist = [[NSTextField alloc]initWithFrame:NSMakeRect(10, 62, 230, 18)];
    [songArtist setFont:[NSFont fontWithName:@"Heiti SC" size:14]];
    [songArtist setTextColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [songArtist setStringValue:@""];
    [songArtist setBezeled:NO];
    [songArtist setDrawsBackground:NO];
    [songArtist setEditable:NO];
    [songArtist setSelectable:NO];
    [songTitle.cell setLineBreakMode:NSLineBreakByTruncatingTail];
    
    //初始化当前已播放时长的lable
    songCurrentPlayTime = [[NSTextField alloc]initWithFrame:NSMakeRect(12, 8, 50, 18)];
    [songCurrentPlayTime setFont:[NSFont fontWithName:@"Heiti SC" size:10]];
    [songCurrentPlayTime setTextColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [songCurrentPlayTime setStringValue:@"00:00"];
    [songCurrentPlayTime setBezeled:NO];
    [songCurrentPlayTime setDrawsBackground:NO];
    [songCurrentPlayTime setEditable:NO];
    [songCurrentPlayTime setSelectable:NO];
    
    //初始化歌曲总时长lable
    songTotleTime = [[NSTextField alloc]initWithFrame:NSMakeRect(362, 8, 50, 18)];
    [songTotleTime setFont:[NSFont fontWithName:@"Heiti SC" size:10]];
    [songTotleTime setTextColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
    [songTotleTime setStringValue:@"00:00"];
    [songTotleTime setBezeled:NO];
    [songTotleTime setDrawsBackground:NO];
    [songTotleTime setEditable:NO];
    [songTotleTime setSelectable:NO];
    
    //初始化播放进度条
    progressBar = [[DWProgressBar alloc]initWithFrame:NSMakeRect(42, 16, 318, 6)];
    [progressBar setAlphaValue:0.6];
    
    //初始化频道选择器
    channleSelector = [[DWChannleSelector alloc]initWithFrame:NSMakeRect(0, 32, 400, 250)];
    
    [self->_window.contentView addSubview:playButtonView];
    [self->_window.contentView addSubview:channleSelector];
    [self->_window.contentView addSubview:rateSongButton];
    [self->_window.contentView addSubview:playNextButton];
    [self->_window.contentView addSubview:neverPlayTheSongButton];
    [self->_window.contentView addSubview:songArtist];
    [self->_window.contentView addSubview:songTitle];
    [self->_window.contentView addSubview:songCurrentPlayTime];
    [self->_window.contentView addSubview:songTotleTime];
    [self->_window.contentView addSubview:progressBar];
    
    NSImage * bgImage = [NSImage imageNamed:@"bgimage.png"];
    [self UpdateAppBackground:bgImage];

    return true;
}

-(void)UpdateAppBackground:(NSImage*)sourceimage
{
    CGFloat x,y,h,w;
    
    if (sourceimage.size.height > sourceimage.size.width)
    {
        y = (sourceimage.size.height - sourceimage.size.width)/2;
        x = 0;
        h = sourceimage.size.width;
        w = sourceimage.size.width;
    }
    else if (sourceimage.size.width > sourceimage.size.height)
    {
        y = 0;
        x = (sourceimage.size.width - sourceimage.size.height)/2;
        h = sourceimage.size.height;
        w = sourceimage.size.height;
    }
    else
    {
        x = 0;
        y = 0;
        h = sourceimage.size.height;
        w = sourceimage.size.width;
    }
    
    NSRect targetRect = NSMakeRect(0, 13, 400, 400);
    NSRect sourceRect = NSMakeRect(x, y, w, h);
    NSRect coverRect = NSMakeRect(0, 110, 400, 132);
    NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(400, 413)];
    NSImage *imageCover = [NSImage imageNamed:@"imageCover.png"];
    NSRect coverSource = NSMakeRect(0, 0, imageCover.size.width, imageCover.size.height);
    
    NSImage * imageMask = [NSImage imageNamed:@"mask.png"] ;
    NSImage *Mask = [[NSImage alloc]initWithSize:NSMakeSize(400, 260)];
    [Mask setBackgroundColor:[NSColor colorWithPatternImage:imageMask]];
    
    [newImage lockFocus];
    [sourceimage drawInRect:targetRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.0];
    [imageCover drawInRect:coverRect fromRect:coverSource operation:NSCompositeSourceOver fraction:1.0];
    [Mask drawInRect:NSMakeRect(0,0,400,600)];
    [newImage unlockFocus];
    [self.window setBackgroundColor:[NSColor colorWithPatternImage:newImage]];
}

-(void)UpdateAppIcon:(NSImage*)sourceimage
{
    CGFloat x,y,h,w;
    
    if (sourceimage.size.height > sourceimage.size.width)
    {
        y = (sourceimage.size.height - sourceimage.size.width)/2;
        x = 0;
        h = sourceimage.size.width;
        w = sourceimage.size.width;
    }
    else if (sourceimage.size.width > sourceimage.size.height)
    {
        y = 0;
        x = (sourceimage.size.width - sourceimage.size.height)/2;
        h = sourceimage.size.height;
        w = sourceimage.size.height;
    }
    else
    {
        x = 0;
        y = 0;
        h = sourceimage.size.height;
        w = sourceimage.size.width;
    }
    
    NSRect targetRect = NSMakeRect(0, 0, 400, 400);
    NSRect sourceRect = NSMakeRect(x, y, w, h);
    
    NSImage *newImage = [[NSImage alloc]initWithSize:NSMakeSize(400, 400)];
    NSImage *musicImage = [NSImage imageNamed:@"music.png"];
    [musicImage setSize:NSMakeSize(100,100 )];
    [newImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:targetRect xRadius:200 yRadius:200];
    [clipPath setWindingRule:NSEvenOddWindingRule];
    [clipPath addClip];
    [sourceimage drawInRect:targetRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1];
    [musicImage drawInRect:targetRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [newImage unlockFocus];
    
    [NSApp setApplicationIconImage:newImage];
}

//观察播放器的当前播放时长，更新当前已播放时长lable和播放进度条状态。
-(void)songplayUpdate:(NSInteger)currentLength TotleLength:(NSInteger)totleLength
{
    NSString *songCurrentTimeMinutes = [NSString stringWithFormat:@"%02ld",currentLength/60];
    NSString *songCurrentTimeSecond = [NSString stringWithFormat:@"%02ld",currentLength%60];
    [self->songCurrentPlayTime setStringValue:[NSString stringWithFormat:@"%@:%@",songCurrentTimeMinutes,songCurrentTimeSecond]];
    self->progressBar.current = currentLength;
}

-(void)channelChange:(CChannel *)channel
{
    if (!(channel==self->player.currentchannel))
    {
        if ([self->player islogined])
        {
            [self->player ChangeChannel:channel];
            self->isPlaying = true;
            [self->playButtonView setHidden:YES];
        }
        else if([channel.channel_id isEqual: @"-3"])
        {
            self->loginaction = LoginActionFavoiteChannel;
            [self->_window beginSheet:[self CreateLoginWindow] completionHandler:nil];
        }
        else
        {
            [self->player ChangeChannel:channel];
            self->isPlaying = true;
            [self->playButtonView setHidden:YES];
        }
    }
}

- (IBAction)PlayPause:(id)sender {

    if(self->isPlaying == TRUE)
    {
        [self->player Pause];
        self->isPlaying = false;
        [self->playButtonView setHidden:NO];
        [self.MenuPalyPause setTitle:@"播放"];
    }
    else
    {
        [self->player Continue];
        self->isPlaying = true;
        [self->playButtonView setHidden:YES];
        [self.MenuPalyPause setTitle:@"暂停"];
    }
}

- (IBAction)playNextAction:(id)sender {
    [self->player Skip];
    self->isPlaying = true;
    [self->playButtonView setHidden:YES];
}

- (IBAction)byeSongAction:(id)sender {
    if ([self->player islogined])
    {
        [self->player ByeSong:self->player.currentsong];
    }
    else
    {
        self->loginaction = LoginActionByeSong;
        [self->_window beginSheet:[self CreateLoginWindow] completionHandler:nil];
    }
    self->isPlaying = true;
    [self->playButtonView setHidden:YES];
}

- (IBAction)rateSongAction:(id)sender {
    
    if ([self->player islogined])
    {
        [self RateSong:self->player.currentsong];
    }
    else
    {
        self->loginaction = LoginActionRateSong;
        [self->_window beginSheet:[self CreateLoginWindow] completionHandler:nil];
    }
}

- (IBAction)MenuLoginAction:(id)sender {
    
    self->loginaction = LoginActionLogin ;
    [self->_window beginSheet:[self CreateLoginWindow] completionHandler:nil];
}


-(void)RateSong:(CSong*)song
{
    if ([song.like isEqual:[NSNumber numberWithInt:1]])
    {
        [self->player UnrateSong:song];
        song.like  = [NSNumber numberWithInt:0];
        [self SwithRateSongButton:OFF];
    }
    else
    {
        [self->player RateSong :song];
        song.like  = [NSNumber numberWithInt:1];
        [self SwithRateSongButton:ON];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    if (flag)
    {
        return NO;
    }
    else
    {
        [self.window makeKeyAndOrderFront:self];
        return YES;
    }
}

-(NSWindow *)CreateLoginWindow
{
    self->loginwindow = [[CDouyaLoginWindow alloc]init];
    
    [loginwindow setFrame:NSMakeRect(0, 0, 210, 245) display:YES];
    
    [loginwindow.CancelButton setAction:@selector(CloseSheetAction:)];
    [loginwindow.YesButton setAction:@selector(LoginAction:)];
    
    return loginwindow;
}

- (IBAction)CloseSheetAction:(id)sender {
    
    [self->loginwindow close];
}

-(IBAction)LoginAction:(id)sender
{
    NSString* username = self->loginwindow.UserNameTbx.stringValue;
    NSString* password = self->loginwindow.PasswordTbx.stringValue;
    
    if ([self->player Login:username Password:password])
    {
        switch (self->loginaction) {
            case LoginActionFavoiteChannel:
                [self->player ChangeChannel:self->channels[0]];
                break;
            
            case LoginActionByeSong:
                [self->player ByeSong:self->player.currentsong];
                break;
                
            case LoginActionRateSong:
                [self RateSong:self->player.currentsong];
                break;
                
            default:
                break;
        }
        [self->loginwindow close];
    }
    else
    {
        [self->loginwindow ShowErrorMessage:@"用户名或者密码错误。"];
    }
}

@end
