//
//  AppDelegate.m
//  DragDropPaste
//
//  Created by Lars Hundebøl on 5/19/12.
//  Copyright (c) 2012 88 Lines of Code. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxOSX/DropboxOSX.h>
#import "URLShortener.h"

@implementation AppDelegate

@synthesize popover = _popover;
@synthesize menuItemStatus = _menuItemStatus;
@synthesize menuItemConnect = _menuItemConnect;


- (void)awakeFromNib {
    pasteBoard = [NSPasteboard generalPasteboard];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    statusItemView = [[StatusItemView alloc] initWithFrame:(NSRect){.size={thickness, thickness}}];
    
    statusItemView.statusItem = statusItem;
    [statusItemView setMenu:statusMenu];
    
    
    [statusItem setView: statusItemView];
    [statusItem setHighlightMode: YES];
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    
    NSString *shortName = ([metadata.filename length] > 20 ? [metadata.filename substringToIndex:20] : metadata.filename);
    
    
    
    self.menuItemStatus.title = [NSString stringWithFormat:@"Uploaded %@", shortName];
    
    NSString *encodedFilename = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)metadata.filename, NULL, (CFStringRef)@"!’\"();:@&=+$,/?%#[]% ", kCFStringEncodingISOLatin1);
    
    NSString *url = [NSString stringWithFormat:@"http://dl.dropbox.com/u/%@/DragDropPaste/%@", dropboxUID, encodedFilename];
    
    if (!urlShortener) {
        urlShortener = [[URLShortener alloc] init];
    }
    
    NSString *shortUrl = [urlShortener shortURL:url];
                          
    [self writeToPasteBoard: shortUrl];
    
    [statusItemView showUploadImage];
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info {
    dropboxUID = [info userId];
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
    if ([[DBSession sharedSession] isLinked]) {
        [statusItemView startAnimating];
        
        NSString *filename = [localPath lastPathComponent];
        NSString *destDir = @"/Public/DragDropPaste/";
        [[self restClient] uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
    }
}

- (BOOL)writeToPasteBoard:(NSString *)stringToWrite
{
    NSLog(@"writeToPasteBoard: %@", stringToWrite);
    [pasteBoard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    return [pasteBoard setString:stringToWrite forType:NSStringPboardType];
}

- (void)updateUI {
    if ([[DBSession sharedSession] isLinked]) {
        [self.restClient loadAccountInfo];
        self.menuItemStatus.title = @"Connected";
        self.menuItemConnect.title = @"Disconnect from Dropbox";
    } else {
        self.menuItemStatus.title = @"Not Connected";
        self.menuItemConnect.title = @"Connect to Dropbox";
        self.menuItemConnect.enabled = ![[DBAuthHelperOSX sharedHelper] isLoading];
    }
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

- (IBAction)showAbout:(id)sender {
    
    NSAttributedString *creditString = [[NSAttributedString alloc] initWithString:@"Brought to you by\nLars Hundebøl"];
    NSString *copyRightString = @"Copyright \xc2\xa9 2012 88 Lines of Code.";
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: creditString,		 @"Credits", copyRightString, @"Copyright", nil];
    [NSApp orderFrontStandardAboutPanelWithOptions:dict];
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
