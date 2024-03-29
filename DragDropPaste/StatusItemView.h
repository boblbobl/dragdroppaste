//
//  StatusItemView.h
//  DragDropPaste
//
//  Created by Lars Hundebøl on 5/20/12.
//  Copyright (c) 2012 88 Lines of Code. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusItemView : NSView <NSMenuDelegate> {
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    NSImage *statusUploadImage;
    BOOL isMenuVisible;
    BOOL isUploadImageVisible;
    NSInteger currentFrame;
    NSTimer* animTimer;
}

@property (assign) NSStatusItem *statusItem;

- (void)showUploadImage;

- (void)startAnimating;

- (void)stopAnimating;

@end
