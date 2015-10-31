//
//  AppDelegate.h
//  DouyaFM
//
//  Created by markof on 15/6/17.
//  Copyright (c) 2015年 markof. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CDoubanFMAPI.h"
#import "CDouyaPlayer.h"
#import "DWProgressBar.h"
#import "DWChannleSelector.h"
#import "CDouyaLoginWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    enum LoginAction
    {LoginActionFavoiteChannel, LoginActionByeSong, LoginActionRateSong, LoginActionLogin};
    
    enum Switch
    {OFF=0,ON=1};

    @private NSArray * channels;
    @private CDouyaPlayer * player;
    @private NSImageView * playButtonView;
    
    @private BOOL isPlaying;
    
    @private NSTextField* songTitle;
    @private NSTextField* songArtist;
    @private NSTextField* songCurrentPlayTime;
    
    @private NSTextField* songTotleTime;
    @private DWProgressBar* progressBar;
    @private DWChannleSelector* channleSelector;
    @private NSButton * rateSongButton;
    
    @private NSImage * RateButtonImage;
    @private NSImage * UnrateButtonImage;
    
    @private CDouyaLoginWindow * loginwindow;
    @private enum LoginAction loginaction;
    
    @private CGPoint windowsPos;
    
}


@end

