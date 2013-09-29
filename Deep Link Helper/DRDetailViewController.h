//
//  DRDetailViewController.h
//  Deep Link Helper
//
//  Created by Sibley on 9/28/13.
//  Copyright (c) 2013 Dr. Jon's Danger Ray, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
