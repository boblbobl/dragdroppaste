//
//  AppDelegate.m
//  DragDropPaste
//
//  Created by Lars Hundebøl on 5/19/12.
//  Copyright (c) 2012 88 Lines of Code. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxOSX/DropboxOSX.h>

@implementation AppDelegate

@synthesize statusLabel = _statusLabel;

@synthesize connectButton = _connectButton;

@synthesize popover = _popover;

@synthesize statusMenu = _statusMenu;

- (void)awakeFromNib {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    statusItemView = [[StatusItemView alloc] initWithFrame:(NSRect){.size={thickness, thickness}}];
    [statusItem setView: statusItemView];

    /*
    [statusItem setMenu:statusMenu];
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setHighlightMode: YES];
     */
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (void)authHelperStateChangedNotification:(NSNotification *)notification {
    NSLog(@"Change UI state.");
    [self updateUI];
    if ([[DBSession sharedSession] isLinked]) {
        // You can now start using the API!
    }
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    // This gets called when the user clicks Show "App name". You don't need to do anything for Dropbox here
}

- (void)uploadFile:(NSString *)localPath {
    NSString *filename = [localPath lastPathComponent];
    NSString *destDir = @"/";
    [[self restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
}

- (void)updateUI {
    NSLog(@"Update UI");
    if ([[DBSession sharedSession] isLinked]) {
        self.statusLabel.stringValue = @"You are now connected to Dropbox.";
        self.connectButton.title = @"Disconnect from Dropbox";
    } else {
        self.statusLabel.stringValue = @"You need to connect to Dropbox for DragDropPaste to work.";
        self.connectButton.title = @"Connect to Dropbox";
        self.connectButton.enabled = ![[DBAuthHelperOSX sharedHelper] isLoading];
    }
}

- (BOOL)isActive {
    return [[self popover] isShown];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *appKey = @"947wfcm3nd717y3";
    NSString *appSecret = @"a3y46lk89il5qeq";
    NSString *root = kDBRootDropbox;
    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    [DBSession setSharedSession:session];
    
    NSDictionary *plist = [[NSBundle mainBundle] infoDictionary];
    NSString *actualScheme = [[[[plist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
    NSString *desiredScheme = [NSString stringWithFormat:@"db-%@", appKey];
    NSString *alertText = nil;
    if ([appKey isEqual:@"APP_KEY"] || [appSecret isEqual:@"APP_SECRET"] || root == nil) {
        alertText = @"Fill in appKey, appSecret, and root in AppDelegate.m to use this app";
    } else if (![actualScheme isEqual:desiredScheme]) {
        alertText = [NSString stringWithFormat:@"Set the url scheme to %@ for the OAuth authorize page to work correctly", desiredScheme];
    }
    
    if (alertText) {
        
        NSLog(@"Alert: %@", alertText);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];
    [self updateUI];
    
    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:)
          forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)closePopover {
    [[self popover] close];
}

- (void)showPopover {
    [[self popover] showRelativeToRect:[statusItemView frame] ofView:statusItemView preferredEdge:NSMaxYEdge];
    
}


- (IBAction)connectToDropbox:(id)sender {
    if ([[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] unlinkAll];
        [self updateUI];
    } else {
        [[DBAuthHelperOSX sharedHelper] authenticate];
    }
    [self closePopover];
}



@end
