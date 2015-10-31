//
//  CDouyaLoginWindow.h
//  DouyaFM
//
//  Created by markof on 15/7/3.
//  Copyright (c) 2015年 markof. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifndef DouyaFM_CDouyaLoginWindow_h
#define DouyaFM_CDouyaLoginWindow_h


#endif

@interface CDouyaLoginWindow : NSWindow
{
    @private NSImageView * ErrorIconView;
    @private NSTextField * ErrorMessageHolder;
}

@property (readonly) NSButton* YesButton;
@property (readonly) NSButton* CancelButton;

@property (readonly) NSTextField* UserNameTbx;
@property (readonly) NSTextField* PasswordTbx;

-(void)ShowErrorMessage:(NSString*)Message;

@end