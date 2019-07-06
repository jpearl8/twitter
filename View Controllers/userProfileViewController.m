//
//  userProfileViewController.m
//  twitter
//
//  Created by jpearl on 7/5/19.
//  Copyright © 2019 Emerson Malca. All rights reserved.
//

#import "userProfileViewController.h"
#import "APIManager.h"
#import "UIImageView+AFNetworking.h"
#import "BDBOAuth1SessionManager.h"
#import "BDBOAuth1SessionManager+SFAuthenticationSession.h"



@interface userProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundIm;
@property (weak, nonatomic) IBOutlet UIImageView *profileIm;
@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *followers;
@property (weak, nonatomic) IBOutlet UILabel *favorites;
@property (weak, nonatomic) IBOutlet UILabel *desc;

@end

@implementation userProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUser];
    NSLog(@"%@", self.accountName.text);
    NSLog(@"%@", self.screenName.text);
    NSLog(@"%@", self.followers.text);
            
//            NSString *profilePicture = currentUser.profPic;
//            NSURL *profilePic = [NSURL URLWithString:profilePicture];
//            self.profileIm.image = nil;
//            [self fadePic:self.profileIm withURL:profilePic];
//            NSString *backgroundPicture = currentUser.profile_background;
//            NSURL *backPic = [NSURL URLWithString:backgroundPicture];
//            self.backgroundIm.image = nil;
////            [self fadePic:self.backgroundIm withURL:backPic];
//            self.accountName.text = currentUser.name;
//            self.screenName.text = currentUser.screenName;
//            self.followers.text = currentUser.followers_count;
//            self.favorites.text = currentUser.favorites_count;
    //self.location.text = currentUser.location;
        //self.desc.text = currentUser.desc;
    
    //
    //self.user.profile_background
    //self.user.profPic
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)fadePic: (UIImageView *)imgFading withURL: (NSURL *)urlProvided{
    NSURLRequest *request = [NSURLRequest requestWithURL:urlProvided];
    [imgFading setImageWithURLRequest:request placeholderImage:nil
      success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
          
          // imageResponse will be nil if the image is cached
          if (imageResponse) {
              NSLog(@"Image was NOT cached, fade in image");
              imgFading.alpha = 0.0;
              imgFading.image = image;

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

-(void)loadUser {
    [[APIManager shared] getCurrentUser:^(User *currentUser, NSError *error) {
        if (currentUser) {
            NSString *profilePicture = currentUser.profPic;
            NSURL *profilePic = [NSURL URLWithString:profilePicture];
            self.profileIm.image = nil;
            [self fadePic:self.profileIm withURL:profilePic];
            NSString *backgroundPicture = currentUser.profile_background;
            NSURL *backPic = [NSURL URLWithString:backgroundPicture];
            self.backgroundIm.image = nil;
            [self fadePic:self.backgroundIm withURL:backPic];
            NSLog(@"%@", currentUser);
            self.accountName.text = currentUser.name;
            self.screenName.text = currentUser.screenName;
            self.followers.text = currentUser.followers_count;
            self.favorites.text = currentUser.favorites_count;
            self.location.text = currentUser.location;
            self.desc.text = currentUser.desc;

        }
    }];
}
@end
