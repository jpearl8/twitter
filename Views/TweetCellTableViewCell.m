//
//  TweetCellTableViewCell.m
//  twitter
//
//  Created by jpearl on 7/1/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//
#import "APIManager.h"
#import "Tweet.h"
#import "TweetCellTableViewCell.h"

@implementation TweetCellTableViewCell
- (IBAction)didReply:(id)sender {
    
}
- (IBAction)didFavorite:(id)sender {
    self.tweet.favorited = !(self.tweet.favorited);
    int x = -1;
    if (self.tweet.favorited){
        [self.favButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
        x = 1;
        
        self.tweet.favoriteCount += 1;
        self.favNum.text = [NSString stringWithFormat:@"%d",self.tweet.favoriteCount];
        NSLog(@"favorited");
    } else {
        [self.favButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
        self.tweet.favoriteCount -= 1;
    }
    [self actionOnTweet:x];
}
- (IBAction)didRetweet:(id)sender {
    self.tweet.retweeted = !(self.tweet.retweeted);
    int x = -2;
    if (self.tweet.retweeted){
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
        x = 2;
        self.tweet.retweetCount += 1;
    } else {
       [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
        self.tweet.retweetCount -= 1;
    }
    [self actionOnTweet:x];
    
}

-(void)actionOnTweet:(int)x {
    [[APIManager shared] action:self.tweet withInt:x withCompletion:^(Tweet *tweet, NSError *error) {
        if(error){
            NSLog(@"Error taking action on tweet: %@", error.localizedDescription);
        }
        else{
            NSLog(@"Successfully took action on the following Tweet: %@", tweet.text);
        }
    }];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.tweet.favorited){
        [self.favButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    } else {
        [self.favButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    }
    if (self.tweet.retweeted){
       [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon-green"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet-icon"] forState:UIControlStateNormal];
    }
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
