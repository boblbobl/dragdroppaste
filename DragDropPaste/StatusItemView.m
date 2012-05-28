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

@synthesize statusItem = _statusItem;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSBundle *bundle = [NSBundle mainBundle];
        
        statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"StatusBarIcon" ofType:@"png"]];
        statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"StatusBarIconInvert" ofType:@"png"]];
        statusUploadImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"StatusBarIconUpload" ofType:@"png"]];
        
        isMenuVisible = NO;
        isUploadImageVisible = NO;
        currentFrame = -1;
        
        [self registerForDraggedTypes: [NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    
    return self;
}

- (void)hideUploadImage:(NSTimer*)timer {
    [self stopAnimating];
}

- (void)showUploadImage {
    [self stopAnimating];
    isUploadImageVisible = YES;
    [self setNeedsDisplay:YES];
    
    animTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(hideUploadImage:) userInfo:nil repeats:NO];
}

- (void)startAnimating
{
    [self stopAnimating];
    currentFrame = 0;
    animTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(updateFrame:) userInfo:nil repeats:YES];
}

- (void)stopAnimating
{
    isUploadImageVisible = NO; 
    currentFrame = -1;
    [animTimer invalidate];
    [self setNeedsDisplay:YES];
}

- (void)updateFrame:(NSTimer*)timer
{    
    if (currentFrame > 6)
        currentFrame = 0;
    else
        currentFrame = currentFrame+1;

    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    dirtyRect = CGRectInset(dirtyRect, 3, 3);
    
    if (currentFrame > -1) {
        NSImage* image = [NSImage imageNamed:[NSString stringWithFormat:@"step-%d", currentFrame]];
        [image drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    else if (isUploadImageVisible) {
        [statusUploadImage drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    else {
        [_statusItem drawStatusBarBackgroundInRect:[self bounds] withHighlight:isMenuVisible];
        
        if (!isMenuVisible) {
            [statusImage drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        }
        else {
            [statusHighlightImage drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
        }
    }
}

- (void)mouseDown:(NSEvent *)event {
    //Make sure to reset icons and stop animation on mouse click
    [self stopAnimating];
    
    [[self menu] setDelegate: self];
    [_statusItem popUpStatusItemMenu:[self menu]];
    [self setNeedsDisplay:YES];
}

#pragma NSMenu Delegate methods 

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
    [menu setDelegate:nil];    
}

#pragma Drag Destination Related

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    [self setNeedsDisplay:YES];
    
    if([[[sender draggingPasteboard] pasteboardItems] count] == 1) {
        return NSDragOperationCopy;
    }
    else {
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    AppDelegate *appDelegate = [NSApp delegate];
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    
    //DESIGN: The for loop, is currently irrelevant since it is only allowed to upload one file.
    for (NSString *filePath in draggedFilenames) {
        [appDelegate uploadFile:filePath];
    }
    
    return YES;
}

@end
