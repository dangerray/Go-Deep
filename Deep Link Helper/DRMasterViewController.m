//
//  DRMasterViewController.m
//  Deep Link Helper
//
//  Created by Sibley on 9/28/13.
//  Copyright (c) 2013 Dr. Jon's Danger Ray, Inc. All rights reserved.
//

#import "DRMasterViewController.h"
#import "DRDetailViewController.h"
#import "DRLink.h"

@interface DRMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation DRMasterViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addButton;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dr_applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];

    if (![GVUserDefaults standardUserDefaults].didSeedDataOnce)
    {
        DRLink *webLink = [self createAndInsertNewLink];
        webLink.title = @"DangerRay.com";
        webLink.url = @"http://www.dangerray.com";

        DRLink *emailLink = [self createAndInsertNewLink];
        emailLink.title = @"Email Us";
        emailLink.url = @"mailto:us@dangerray.com";

        DRLink *twitterLink = [self createAndInsertNewLink];
        twitterLink.title = @"Dr. Jon's Danger Ray on Twitter";
        twitterLink.url = @"twitter://user?screen_name=DrJonsDangerRay";

        DRLink *htLink = [self createAndInsertNewLink];
        htLink.title = @"HotelTonight: San Francisco";
        htLink.url = @"hoteltonight://market/1";

        DRLink *callAppleStoreLink = [self createAndInsertNewLink];
        callAppleStoreLink.title = @"Call Apple Store";
        callAppleStoreLink.url = @"tel:+1-800-MY-APPLE";

        [self saveManagedObjectContextForFetchedResultsController];

        [GVUserDefaults standardUserDefaults].didSeedDataOnce = YES;
    }
}

#pragma mark - Actions

- (void)addButtonPressed:(id)sender
{
    DRLink *newLink = [self createAndInsertNewLink];
    newLink.timeStamp = [NSDate date];

    // Save the context
    BOOL didSave = [self saveManagedObjectContextForFetchedResultsController];
    if (didSave)
    {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                    animated:NO
                              scrollPosition:UITableViewScrollPositionNone];
        [self performSegueWithIdentifier:@"addNewLink" sender:newLink];
    }

    [[Mixpanel sharedInstance] track:@"app.master.add.pressed" properties:nil];
}

#pragma mark - Public

- (DRLink *)createAndInsertNewLink
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    DRLink *link = (DRLink *)[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];

    HTAssertSimulatorOnly([link isKindOfClass:[DRLink class]], nil);

    return link;
}

#pragma mark - Private

- (void)dr_applicationDidBecomeActive:(NSNotification *)notification
{
    if ([self.tableView indexPathForSelectedRow])
    {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

- (BOOL)saveManagedObjectContextForFetchedResultsController
{
    NSError *error = nil;
    BOOL didSave = [[self.fetchedResultsController managedObjectContext] save:&error];
    if (!didSave)
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"For some reason we're having trouble creating a new link!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return didSave;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger numberOfRows = [sectionInfo numberOfObjects];

    if (!numberOfRows)
    {
        [self.navigationItem setLeftBarButtonItem:nil animated:YES];

        if ([self.tableView isEditing])
        {
            [self.tableView setEditing:NO animated:NO];
        }
    }
    else
    {
        [self.navigationItem setLeftBarButtonItem:self.editButtonItem animated:YES];
    }

    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"For some reason we're having trouble making that change!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DRLink *link = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [link openURL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        DRLink *link = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DRDetailViewController *viewController = [segue destinationViewController];
        viewController.managedObjectContext = self.managedObjectContext;
        viewController.link = link;

        HTAssertSimulatorOnly(link, nil);
    }
    else if ([[segue identifier] isEqualToString:@"addNewLink"])
    {
        DRLink *link = (DRLink *)sender;
        DRDetailViewController *viewController = [segue destinationViewController];
        viewController.managedObjectContext = self.managedObjectContext;
        viewController.link = link;

        HTAssertSimulatorOnly([link isKindOfClass:[DRLink class]], nil);
        HTAssertSimulatorOnly(link, nil);
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DRLink" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
    {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"For some reason we're having trouble with our database!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DRLink *link = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = link.title;
    cell.detailTextLabel.text = link.url;
}

@end
