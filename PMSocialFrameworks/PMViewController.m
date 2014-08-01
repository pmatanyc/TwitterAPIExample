//
//  PMViewController.m
//  PMSocialFrameworks
//
//  Created by Paola Mata Maldonado on 7/22/14.
//
//

#import "PMViewController.h"
#import <Accounts/Accounts.h>

@interface PMViewController ()

@property (nonatomic)ACAccountStore *accountStore;

@end

@implementation PMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.accountStore = [[ACAccountStore alloc]init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self fetchTwitterTimelineForUser:@"pmatanyc"];
}


-(IBAction)shareToFacebook:(id)sender{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *fbPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbPost setInitialText:@"TurnToTech - NYC"];
        [fbPost addURL:[NSURL URLWithString:@"http://turntotech.io"]];
        
        [self presentViewController:fbPost animated:YES completion:nil];
    }
    else {
        NSLog(@"Facebook not available");
    }
}


-(IBAction)shareToTwitter:(id)sender{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *twPost= [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twPost setInitialText:@"TurnToTech - NYC"];
        [twPost addURL:[NSURL URLWithString:@"http://turntotech.io"]];
        [self presentViewController:twPost animated:YES completion:nil];
    }
    else {
        NSLog(@"Twitter not available");
    }

}

- (void)fetchTwitterTimelineForUser:(NSString *)username
{
    
    //  Step 0: Check that the user has local Twitter accounts
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [self.accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/user_timeline.json"];
                 
                 NSDictionary *params = @{@"screen_name" : username,
                                          @"include_rts" : @"0",
                                          @"trim_user" : @"1",
                                          @"count" : @"1"};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:
                  ^(NSData *responseData,
                    NSHTTPURLResponse *urlResponse,
                    NSError *error) {
                      
                      if (responseData) {
                          if (urlResponse.statusCode >= 200 &&
                              urlResponse.statusCode < 300) {
                              
                              NSError *jsonError;
                              NSArray *timelineData = [NSJSONSerialization
                                                            JSONObjectWithData:responseData
                                                            options:NSJSONReadingAllowFragments
                                                            error:&jsonError];
                              
                              if (timelineData) {
                                  NSDictionary *dict = [timelineData objectAtIndex:0];
                                  NSLog(@"Timeline Response: %@",[dict objectForKey:@"text"]);
                                  
                                  NSString *tweet = [NSString stringWithFormat:@"Latest tweet from @%@: \n%@", username,[dict objectForKey:@"text"]];
                                 
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                        self.label.text = tweet;
                                  });
                              }
                              else {
                                  // Our JSON deserialization went awry
                                  NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                              }
                          }
                          else {
                              // The server did not respond ... were we rate-limited?
                              NSLog(@"The response status code is %ld",
                                    (long)urlResponse.statusCode);
                          }
                      }
                  }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"%@", [error localizedDescription]);
             }
         }];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
