//
//  DRDetailViewController.m
//  Deep Link Helper
//
//  Created by Sibley on 9/28/13.
//  Copyright (c) 2013 Dr. Jon's Danger Ray, Inc. All rights reserved.
//

#import "DRDetailViewController.h"
#import "DRLink.h"
#import <QuartzCore/QuartzCore.h>

@interface DRDetailViewController ()
- (void)configureView;
@end

@implementation DRDetailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.titleTextField];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.urlTextField];
}

#pragma mark - Managing the detail item

- (void)setLink:(id)newLink
{
    if (_link != newLink)
    {
        _link = newLink;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    if (self.link)
    {
        self.titleTextField.text = self.link.title;
        self.urlTextField.text = self.link.url;

        [self updateUrlTextFieldBorderColor];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.titleTextField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(urlTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:self.urlTextField];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.titleTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (![self.link.url length] && ![self.link.title length])
    {
        [self deleteLink];
    }
    else
    {
        [self save];
    }
}

#pragma mark - Notifications

- (void)urlTextFieldDidChange:(NSNotification *)notification
{
    self.link.url = self.urlTextField.text;
    [self updateUrlTextFieldBorderColor];
}

- (void)titleTextFieldDidChange:(NSNotification *)notification
{
    self.link.title = self.titleTextField.text;
}

#pragma mark - Actions

- (IBAction)deleteButtonPressed:(id)sender
{
    [self deleteLink];
}

- (IBAction)testLinkButtonPressed:(id)sender
{
    [self.link openURL];
}


#pragma mark - Private

- (void)updateUrlTextFieldBorderColor
{
    if ([self.urlTextField.text length])
    {
        NSURL *url = [NSURL URLWithString:self.urlTextField.text];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            self.urlTextField.backgroundColor = [UIColor greenColor];
        }
        else
        {
            self.urlTextField.backgroundColor = [UIColor redColor];
        }
    }
    else
    {
        self.urlTextField.backgroundColor = [UIColor whiteColor];
    }
}

- (void)deleteLink
{
    if (self.link)
    {
        [self.managedObjectContext deleteObject:self.link];
        self.link = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)save
{
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"For some reason we're having trouble saving this link!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.titleTextField)
    {
        self.link.title = self.titleTextField.text;
    }
    else if (textField == self.urlTextField)
    {
        self.link.url = self.urlTextField.text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.titleTextField)
    {
        [self.urlTextField becomeFirstResponder];
    }
    else if (textField == self.urlTextField)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }

    return YES;
}

@end
