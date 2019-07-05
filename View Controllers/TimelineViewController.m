//
//  TimelineViewController.m
//  twitter
//
//  Created by emersonmalca on 5/28/18.
//  Copyright © 2018 Emerson Malca. All rights reserved.
//

#import "TimelineViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "TweetCellTableViewCell.h"
#import "Tweet.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "viewTweetViewController.h"


@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
- (IBAction)didLogout:(id)sender;

@property (strong, nonatomic) NSArray<Tweet *> *tweets;
- (IBAction)tapFav:(id)sender;
- (IBAction)tapRetweet:(id)sender;
- (IBAction)tapReply:(id)sender;



@property (weak, nonatomic) IBOutlet UITableView *tableTweets;
// 1. view controller has a tableView as a subview

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (assign, nonatomic) BOOL isMoreDataLoading;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 3. view controller becomes its dataSource and delegate in viewDidLoad
    self.tableTweets.dataSource = self;
    self.tableTweets.delegate = self;
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableTweets insertSubview:refreshControl atIndex:0];
    // Get timeline
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray<Tweet *>*tweets, NSError *error) {
        if (tweets) {
            self.tweets = tweets;
            NSLog(@"😎😎😎 Successfully loaded home timeline");
            for (Tweet *tweet in tweets) {
                NSString *text = tweet.text;
                NSLog(@"%@", text);
               
            }
            
           [self.tableTweets reloadData];
        } else {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        }
        
       
    }];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 8a. table view asks numberOfRows
// 9. numberOfRows returns number of items returned from the API
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"COUNT!");
    NSLog(@"%i", self.tweets.count);
    return self.tweets.count;
}

// 8b. cellsForRowAt
// 10. cellsForRow returns an instance of the custom cell with that reuse identifier with its elements populated with data at the index asked for
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"TweetCell"];
    // 2b: custom table view cell set to reuse idnetifier
    if ([self.tweets[indexPath.row] isKindOfClass: Tweet.class]) {
        
        Tweet *tweet1 =  self.tweets[indexPath.row];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tweet = tweet1;
        cell.tweetText.text = tweet1.text;
        cell.accountName.text = tweet1.user.name;
        cell.retweetNum.text = [NSString stringWithFormat:@"%i", tweet1.retweetCount];
        cell.favNum.text = [NSString stringWithFormat:@"%i", tweet1.favoriteCount];
        cell.replyNum.text = [NSString stringWithFormat:@"%i", tweet1.favoriteCount];
        cell.date.text = tweet1.createdAtString;
        cell.screenName.text = tweet1.user.screenName;
        NSString *profilePicture = tweet1.user.profPic;
        NSURL *profilePic = [NSURL URLWithString:profilePicture];
        cell.profileIm.image = nil;
        [self fadePic:cell.profileIm withURL:profilePic];
    } else if ([self.tweets[indexPath.row] isKindOfClass: NSDictionary.class]) {
        NSLog(@"wrong!");
    }
    
    return cell;
}


-(void)fadePic: (UIImageView *)imgFading withURL: (NSURL *)urlProvided{
    NSURLRequest *request = [NSURLRequest requestWithURL:urlProvided];
    [imgFading setImageWithURLRequest:request placeholderImage:nil
  success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
      
      // imageResponse will be nil if the image is cached
      if (imageResponse) {
          NSLog(@"Image was NOT cached, fade in image");
          imgFading.alpha = 0.0;
          imgFading.image = image;
          
          //Animate UIImageView back to alpha 1 over 0.3sec
          [UIView animateWithDuration:0.8 animations:^{
              imgFading.alpha = 1.0;
          }];
      }
      else {
          NSLog(@"Image was cached so just update the image");
          imgFading.image = image;
      }
  }
  failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
      // do something for the failure condition
  }];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {

    // Create NSURL and NSURLRequest
     [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (tweets) {
            // lookup Nself.tweets = tweets;
            //insertObjects:(NSArray<ObjectType> *)objects atIndexes:(NSIndexSet *)indexes;
           // [self.tweets addObject:tweets];
            // 6. reload table view
            self.tweets = tweets;
            [self.tableTweets reloadData];
        }

        [refreshControl endRefreshing];
        //
        

    }];

    //[task resume];
}

-(void)loadMoreData{
    
    [[APIManager shared] getHomeTimelineWithCompletion:^(NSArray *tweets, NSError *error) {
        if (error != nil) {
            
        }
        else
        {

            // Update flag
            self.isMoreDataLoading = false;
            //[self.tweets addObject:tweets];
            self.tweets = tweets;
            //self.tableTweets.dataSource = self;
            //self.tableTweets.delegate = self;
            // ... Use the new data to update the data source ...
            
            // Reload the tableView now that there is new data
            
            [self.tableTweets reloadData];
            
        }
    }];
    //[task resume];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Handle scroll behavior here
    if(!self.isMoreDataLoading){
        int scrollViewContentHeight = self.tableTweets.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.tableTweets.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableTweets.isDragging) {
            self.isMoreDataLoading = true;
            [self loadMoreData];
        }
        
    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    TweetCellTableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableTweets indexPathForCell:tappedCell];
    if (indexPath.row){
        Tweet *tweet = self.tweets[indexPath.row];
        viewTweetViewController *viewTweetViewController1 = [segue destinationViewController];
        viewTweetViewController1.tweet = tweet;
        NSLog(@"tapped on a tweet");
    }
}



- (IBAction)tapFav:(id)sender {
    [self.tableTweets reloadData];
}

- (IBAction)tapRetweet:(id)sender {
    [self.tableTweets reloadData];
}


- (IBAction)tapReply:(id)sender {
    [self.tableTweets reloadData];
}

- (IBAction)didLogout:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    appDelegate.window.rootViewController = loginViewController;
    [[APIManager shared] logout];
}
@end
