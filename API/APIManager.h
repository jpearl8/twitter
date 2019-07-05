//
//  APIManager.h
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//
#import "Tweet.h"
#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"

@interface APIManager : BDBOAuth1SessionManager
// 4. Make an API request
+ (instancetype)shared;
// 5. API manager calls the completion handler passing back data
// 6. View controller stores that data passed into the completion handler
- (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion;
- (void)getHomeTimelineWithCompletion:(void(^)(NSArray <Tweet*>*tweets, NSError *error))completion;
//- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion;
- (void)action:(Tweet *)tweet withInt:(int)x withCompletion:(void (^)(Tweet *, NSError *))completion;
// support other API requests: get user timeline, favorite tweet, retweet,

@end
