//
//  StatusItemView.m
//  DragDropPaste
//
//  Created by Lars Hundebøl on 5/20/12.
//  Copyright (c) 2012 88 Lines of Code. All rights reserved.
//

#import "StatusItemView.h"
#import "AppDelegate.h"

@implementation StatusItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSBundle *bundle = [NSBundle mainBundle];
        
        statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"StatusBarIcon" ofType:@"png"]];
        statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"StatusBarIconAlt" ofType:@"png"]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    dirtyRect = CGRectInset(dirtyRect, 2, 2);
    [statusImage drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)mouseDown:(NSEvent *)event 
{
    AppDelegate *appDelegate = [NSApp delegate];
    
    if ([appDelegate isActive]) {
        [appDelegate closePopover];
    }
    else {
        [appDelegate showPopover];
    }
}

@end
