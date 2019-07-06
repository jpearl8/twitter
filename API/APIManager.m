//
//  APIManager.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "APIManager.h"
#import "Tweet.h"



static NSString * const baseURLString = @"https://api.twitter.com";




static NSString * const consumerKey = @"EmvsPpBiPS99Rq2ew8W034NbK";// Enter your consumer key here
static NSString * const consumerSecret = @"ZohXFYQBWIwQAyjuyafxhRaHQpNVTdj4F7nKhJItp9apSfQIli";// Enter your consumer secret here

@interface APIManager()

@end

@implementation APIManager

+ (instancetype)shared {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSString *key = consumerKey;
    NSString *secret = consumerSecret;
    // Check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"]) {
        key = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-key"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"]) {
        secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"consumer-secret"];
    }
    
    self = [super initWithBaseURL:baseURL consumerKey:key consumerSecret:secret];
    if (self) {
        
    }
    return self;
}

- (void)getCurrentUser:(void(^)(User *currentUser, NSError *error))completion {
    
    
    // READ FROM DISK FIRST
    // Fetch tweets from cache if possible (reading from disk)
    NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"current_user"];
    if (data != nil) {
        NSDictionary *currentUserDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        completion([[User alloc] initWithDictionary:currentUserDictionary], nil);
    } else {
        // data was not available on disk (hasn't been written yet)
        
        // fetch user data from Twitter API (make a GET Request)
        [self GET:@"1.1/account/verify_credentials.json"
       parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable userDictionary) {
           // Success
           
           // write to disk
           // Manually cache the tweets (write to disk)
           NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userDictionary];
           [[NSUserDefaults standardUserDefaults] setValue:data forKey:@"current_user"];
           
           // return in completion
           completion([[User alloc] initWithDictionary:userDictionary], nil);
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           
           completion(nil, error);
       }];
        
    }
    
    
    
    
}

-(void)getUserTimelineWithCompletion:(NSString *)screenName withCompletion: (void(^)(NSArray<Tweet *>*tweets, NSError *error))completion {
    if (screenName){
    // Create a GET Request
        NSString *baseURL = @"1.1/statuses/user_timeline.json?screen_name=";

        NSString *fullString = [[baseURL stringByAppendingString:screenName] stringByAppendingString: @"&count=20"];
        NSLog(@"this the string we made:");
        NSLog(@"%@", fullString);
        [self GET:fullString
        parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
            // Success
            NSLog(@"SUCCESS!");
            NSMutableArray<Tweet *>*tweets  = [Tweet tweetsWithArray:tweetDictionaries];
            completion(tweets, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"fail!");
            // There was a problem
            //completion(nil, error);
            NSArray <NSDictionary*> *tweetDictionaries = nil;
            NSMutableArray<Tweet *>*tweets = nil;
            // Fetch tweets from cache if possible
            NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:screenName];
            if (data != nil) {
                tweetDictionaries = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                tweets  = [Tweet tweetsWithArray:tweetDictionaries];
            }
            
            completion(tweets, error);
        }];
    }
}


- (void)getHomeTimelineWithCompletion:(void(^)(NSArray<Tweet *>*tweets, NSError *error))completion {
    
    // Create a GET Request
    [self GET:@"1.1/statuses/home_timeline.json"
    parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSArray *  _Nullable tweetDictionaries) {
        // Success

        NSMutableArray<Tweet *>*tweets  = [Tweet tweetsWithArray:tweetDictionaries];
        completion(tweets, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // There was a problem
        //completion(nil, error);
        NSArray <NSDictionary*> *tweetDictionaries = nil;
        NSMutableArray<Tweet *>*tweets = nil;
        // Fetch tweets from cache if possible
        NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"hometimeline_tweets"];
        if (data != nil) {
            tweetDictionaries = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            tweets  = [Tweet tweetsWithArray:tweetDictionaries];
        }
        
        completion(tweets, error);
    }];
}

- (void)postStatusWithText:(NSString *)text completion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = @"1.1/statuses/update.json";
    NSDictionary *parameters = @{@"status": text};
    
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc] initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}


- (void)action:(Tweet *)tweet withInt:(int)x withCompletion:(void (^)(Tweet *, NSError *))completion{
    NSString *urlString = nil;
    // 1 for favorite, -1 for unfavorite, 2 for retweet, -2 for unretweet
    if (x == 1){
        urlString = @"1.1/favorites/create.json";
    } else if (x == -1){
        urlString = @"1.1/favorites/destroy.json";
    } else if (x == 2){
        urlString = @"1.1/statuses/retweet.json";
    } else if (x == -2){
        urlString = @"1.1/statuses/unretweet.json";
    }
    NSDictionary *parameters = @{@"id": tweet.idStr};
    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
        completion(tweet, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}


@end
