//
//  AppDelegate.h
//  DragDropPaste
//
//  Created by Lars Hundebøl on 5/19/12.
//  Copyright (c) 2012 88 Lines of Code. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DropboxOSX/DropboxOSX.h>
#import "StatusItemView.h"



@interface AppDelegate : NSObject <NSApplicationDelegate, DBRestClientDelegate> {
    DBRestClient *restClient;
    NSStatusItem *statusItem;
    StatusItemView *statusItemView;
}

@property (assign) IBOutlet NSTextField *statusLabel;

@property (assign) IBOutlet NSMenu *statusMenu;

@property (assign) IBOutlet NSButton *connectButton;

@property (assign) IBOutlet NSPopover *popover;

- (IBAction)connectToDropbox:(id)sender;

- (void)showPopover;

- (void)closePopover;

- (void)updateUI;

- (void)uploadFile:(NSString *)fileName;

- (BOOL)isActive;

@end
