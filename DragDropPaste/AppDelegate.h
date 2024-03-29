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
#import "AboutController.h"
#import "URLShortener.h"


@interface AppDelegate : NSObject <NSApplicationDelegate, DBRestClientDelegate> {
    NSString *dropboxUID;
    NSPasteboard *pasteBoard;
    DBRestClient *restClient;
    NSStatusItem *statusItem;
    StatusItemView *statusItemView;
    AboutController *aboutController;
    URLShortener *urlShortener;
    IBOutlet NSMenu *statusMenu;
    
    NSImage *statusImage;
    NSImage *statusHighlightImage;
}

@property (assign) IBOutlet NSMenuItem *menuItemStatus;

@property (assign) IBOutlet NSMenuItem *menuItemConnect;

@property (assign) IBOutlet NSPopover *popover;

- (IBAction)showAbout:(id)sender;

- (IBAction)connectToDropbox:(id)sender;

- (void)showPopover;

- (void)closePopover;

- (void)updateUI;

- (void)uploadFile:(NSString *)fileName;

- (BOOL)writeToPasteBoard:(NSString *)stringToWrite;

@end
