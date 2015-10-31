//
//  NetDiagnose.m
//  DouyaFM
//
//  Created by markof on 15/7/8.
//  Copyright (c) 2015年 markof. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetDiagnose.h"

@implementation NetDiagnose : NSObject


-(void)StartNotification
{
    CFStringRef urlstring =  CFSTR("www.douban.com");
    CFURLRef url = CFURLCreateWithString(NULL, urlstring, NULL);
    CFNetDiagnosticRef status = CFNetDiagnosticCreateWithURL(NULL, url);
    
    CFNetDiagnosticStatus netstatus = CFNetDiagnosticCopyNetworkStatusPassively(status,NULL);
    
    NSTimer *timer;
    
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                             target: self
                                           selector: @selector(handleTimer:)
                                           userInfo: nil
                                            repeats: YES];
}


@end