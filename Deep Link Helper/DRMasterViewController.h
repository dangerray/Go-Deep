//
//  DRMasterViewController.h
//  Deep Link Helper
//
//  Created by Sibley on 9/28/13.
//  Copyright (c) 2013 Dr. Jon's Danger Ray, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface DRMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
