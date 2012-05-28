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
        
        isMenuVisible = NO;
        
        [self registerForDraggedTypes: [NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    
    return self;
}

- (void)startAnimating
{
    currentFrame = 0;
    animTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0 target:self selector:@selector(updateImage:) userInfo:nil repeats:YES];
}

- (void)stopAnimating
{
    currentFrame = -1;
    [animTimer invalidate];
    [self setNeedsDisplay:YES];
}

- (void)updateImage:(NSTimer*)timer
{
    NSString *imageName = [NSString stringWithFormat:@"step-%d", currentFrame];
    NSLog(@"Set image: %@", imageName);
    
    if (currentFrame > 6)
        currentFrame = 0;
    else
        currentFrame = currentFrame+1;
    
    /*
    NSImage* image = [NSImage imageNamed:[NSString stringWithFormat:@"step-%d",currentFrame]];
    [statusImage setImage:image];
    */
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    //NSLog(@"drawRect");
    
    dirtyRect = CGRectInset(dirtyRect, 3, 3);
    
    if (currentFrame > -1) {
        NSImage* image = [NSImage imageNamed:[NSString stringWithFormat:@"step-%d", currentFrame]];
        [image drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
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
        NSLog(@"Uploading %@", filePath);
        [appDelegate uploadFile:filePath];
    }
    
    return YES;
}

@end
