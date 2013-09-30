#import "DRLink.h"


@interface DRLink ()

// Private interface goes here.

@end


@implementation DRLink

- (void)openURL
{
    NSURL *url = [NSURL URLWithString:self.url];
    
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[Mixpanel sharedInstance] track:@"app.url.launch.success" properties:nil];
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        [[Mixpanel sharedInstance] track:@"app.url.launch.fail" properties:nil];
        [[[UIAlertView alloc] initWithTitle:@"Oops!"
                                    message:@"Your iOS device doesn't know how to handle that URL."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end
