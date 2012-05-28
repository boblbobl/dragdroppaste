//
//  URLShortener.m
//  Digibron
//
//  Created by haltink on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "URLShortener.h"
//#import "JSON.h"

@implementation URLShortener

- (NSString *)shortURL:(NSString *)longURL
{
    NSString *post = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}", longURL];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://www.googleapis.com/urlshortener/v1/url"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
	NSError *error;
    NSData *urlData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&response
                                                        error:&error];
    
    NSString *responseString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    
    
    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if ([json respondsToSelector:@selector(objectForKey:)]) {
        NSLog(@"JSON result");
        return [json objectForKey:@"id"];
    }
    else {
        return longURL;
    }
    
}

@end
