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
        
        [self registerForDraggedTypes: [NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    dirtyRect = CGRectInset(dirtyRect, 2, 2);
    /*[statusImage drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];*/
    
    AppDelegate *appDelegate = [NSApp delegate];
    
    if ([appDelegate isActive]) {
        [[NSColor selectedMenuItemColor] set]; /* blueish */
    } else {
        [[NSColor textColor] set]; /* blackish */ 
    }
    NSRectFill(dirtyRect);  
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

#pragma Drag Destination Related

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSLog(@"draggingEntered");
    //TODO: Do something here...
    
    [self setNeedsDisplay:YES];
    
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    NSLog(@"draggingExited");
    
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"prepareForDragOperation");
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSLog(@"performDragOperation");
    
    AppDelegate *appDelegate = [NSApp delegate];
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    
    for (NSString *filePath in draggedFilenames) {
        NSLog(@"Uploading %@", filePath);
        [appDelegate uploadFile:filePath];
    }
    
    return YES;
}

@end
