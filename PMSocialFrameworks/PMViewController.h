//
//  PMViewController.h
//  PMSocialFrameworks
//
//  Created by Paola Mata Maldonado on 7/22/14.
//
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface PMViewController : UIViewController

@property(nonatomic) NSDictionary *tweetData;
@property(nonatomic) IBOutlet UILabel *label;


-(IBAction)shareToFacebook:(id)sender;
-(IBAction)shareToTwitter:(id)sender;

@end
