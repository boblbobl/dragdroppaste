//
//  AboutController.m
//  DragDropPaste
//
//  Created by Lars Hundebøl on 5/25/12.
//  Copyright (c) 2012 88 Lines of Code. All rights reserved.
//

#import "AboutController.h"

@implementation AboutController

@synthesize versionText = _versionText;

-(id)init {
    if (![super initWithWindowNibName:@"About"])
        return nil;
    return self;
}

-(void)windowDidLoad {
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *version = [[bundle infoDictionary] valueForKey:@"CFBundleVersion"];
    _versionText.stringValue = version;
}

@end
