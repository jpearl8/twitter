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
//
//static NSString * const consumerKey = @"5lUJuO5AUpPUCez4ewYDFrtgh";
//static NSString * const consumerSecret = @"s5ynGqXzstUZwFPxVyMDkYh197qvHOcVM3kwv1o2TKhS1avCdS";

static NSString * const consumerKey = @"nyGyVEEb8HN9jsc8z3UWTrnLL";// Enter your consumer key here
static NSString * const consumerSecret = @"ZwPS3fptwvRwRLFlufjPkj4TEMahvZBTKIBLPCrouLvNdYHlHe";// Enter your consumer secret here

// create an array of tweets to add to the gethometimelinewithcompletion method??
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

//- (void)favorite:(Tweet *)tweet completion:(void (^)(Tweet *, NSError *))completion{
//
//    NSString *urlString = @"1.1/favorites/create.json";
//    NSDictionary *parameters = @{@"id": tweet.idStr};
//    [self POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable tweetDictionary) {
//        Tweet *tweet = [[Tweet alloc]initWithDictionary:tweetDictionary];
//        completion(tweet, nil);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        completion(nil, error);
//    }];
//}

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
