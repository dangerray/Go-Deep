//
//  DRAboutViewController.m
//  Deep Link Helper
//
//  Created by Sibley on 9/28/13.
//  Copyright (c) 2013 Dr. Jon's Danger Ray, Inc. All rights reserved.
//

#import "DRAboutViewController.h"

@interface DRAboutViewController ()

@end

@implementation DRAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Actions

- (IBAction)shareButtonPressed:(id)sender
{
    NSString *shareText = NSLocalizedString(@"Check out Deep Link Helper, an app to help you test deep links: https://itunes.apple.com/us/app/deep-link-helper-open-any/id717821942?ls=1&mt=8", nil);
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[ shareText ] applicationActivities:nil];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (IBAction)closeButtonPressed:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getInTouchButtonPressed:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"mailto:us@dangerray.com"];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                    message:@"Your iOS device can't send email."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
