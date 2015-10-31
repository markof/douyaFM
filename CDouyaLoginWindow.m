//
//  CDouyaLoginWindow.m
//  DouyaFM
//
//  Created by markof on 15/7/3.
//  Copyright (c) 2015年 markof. All rights reserved.
//

#import "CDouyaLoginWindow.h"


@implementation CDouyaLoginWindow:NSWindow

-(CDouyaLoginWindow*)init
{
    self = [super init];
    
    [self initialUserInterface];
    
    return self;
}

-(void)initialUserInterface
{
    self->_YesButton = [[NSButton alloc]initWithFrame:NSMakeRect(105, 10, 90, 24)];
    [self.YesButton setTitle:@"确定"];
    [self.YesButton setBezelStyle:NSRoundedBezelStyle];
    [self.YesButton highlight:YES];
    
    self->_CancelButton = [[NSButton alloc]initWithFrame:NSMakeRect(14, 10, 90, 24)];
    [self.CancelButton setTitle:@"取消"];
    [self.CancelButton setBezelStyle:NSRoundedBezelStyle];
    
    self->_UserNameTbx = [[NSTextField alloc]initWithFrame:NSMakeRect(20, 100, 170, 32)];
    [self.UserNameTbx setBezelStyle:NSTextFieldRoundedBezel];
    [self.UserNameTbx setFont:[NSFont fontWithName:@"Heiti SC" size:12]];
    [self.UserNameTbx setPlaceholderString:@"豆瓣账号"];

    self->_PasswordTbx = [[NSSecureTextField alloc]initWithFrame:NSMakeRect(20, 70, 170, 32)];
    [self.PasswordTbx setBezelStyle:NSTextFieldRoundedBezel];
    [self.PasswordTbx setFont:[NSFont fontWithName:@"Heiti SC" size:12]];
    [self.PasswordTbx setPlaceholderString:@"密码"];
    
    NSImage * LogoImage = [NSImage imageNamed :@"DoubanLogo.png"];
    NSImageView * LogoImageView = [[NSImageView alloc]initWithFrame:NSMakeRect(20, 130, 170, 83)];
    [LogoImageView setImage:LogoImage];
    
    NSImage * ErrorIcon = [NSImage imageNamed :@"erroricon.png"];
    ErrorIconView = [[NSImageView alloc]initWithFrame:NSMakeRect(20, 50, 12, 12)];
    [ErrorIconView setImage:ErrorIcon];
    
    ErrorMessageHolder = [[NSTextField alloc]initWithFrame:NSMakeRect(37, 41, 150, 24)];
    [ErrorMessageHolder setBezeled:NO];
    [ErrorMessageHolder setDrawsBackground:NO];
    [ErrorMessageHolder setEditable:NO];
    [ErrorMessageHolder setSelectable:NO];
    [ErrorMessageHolder.cell setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [ErrorIconView setHidden:YES];
    [ErrorMessageHolder setHidden:YES];
    
    [self setAlphaValue:0.98];
    
    [self.contentView addSubview:self.YesButton];
    [self.contentView addSubview:self.CancelButton];
    [self.contentView addSubview:self.UserNameTbx];
    [self.contentView addSubview:self.PasswordTbx];
    [self.contentView addSubview:LogoImageView];
    [self.contentView addSubview:ErrorIconView];
    [self.contentView addSubview:ErrorMessageHolder];
}

-(void)ShowErrorMessage:(NSString*)Message
{
    [ErrorMessageHolder setStringValue:Message];
    [ErrorIconView setHidden:NO];
    [ErrorMessageHolder setHidden:NO];
}


@end