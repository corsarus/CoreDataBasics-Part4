//
//  CCRPublishersTableViewController.m
//  CoreDataBasics-Part2
//
//  Created by admin on 10/02/15.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import "CCRPublishersTableViewController.h"
#import "CCRBooksTableViewController.h"

#import "AppDelegate.h"
#import <CoreData/CoreData.h>

@interface CCRPublishersTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CCRPublishersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register for iCloud updates notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePublishersTableView) name:CDUpdateUINotification object:nil];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
        NSEntityDescription *publisherEntityDescription = [NSEntityDescription entityForName:@"Publisher" inManagedObjectContext:[self appDelegate].managedObjectContext];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = publisherEntityDescription;
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[self appDelegate].managedObjectContext
                                                                          sectionNameKeyPath:@"firstLetter"
                                                                                   cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *error = nil;
        [_fetchedResultsController performFetch:&error];
        
        if (error) {
            NSLog(@"Error while loading data: %@", error.localizedDescription);
        }
        
    }
    
    return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.fetchedResultsController.sections[section] name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSManagedObject *publisher = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [publisher valueForKey:@"name"];
    
    return cell;
}

#pragma mark - NSFetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView beginUpdates];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSArray *newIndexPathArray = nil;
    NSArray *oldIndexPathArray = nil;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            newIndexPathArray = @[newIndexPath];
            [[self tableView] insertRowsAtIndexPaths:newIndexPathArray
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            oldIndexPathArray = @[indexPath];
            [[self tableView] deleteRowsAtIndexPaths:oldIndexPathArray
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            NSManagedObject *publisher = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = [publisher valueForKey:@"name"];
            
            break;
        }
            
        case NSFetchedResultsChangeMove:
            newIndexPathArray = @[newIndexPath];
            oldIndexPathArray = @[indexPath];
            
            [[self tableView] deleteRowsAtIndexPaths:oldIndexPathArray
                                    withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:newIndexPathArray
                                    withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView endUpdates];
    
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showBooks"]) {
        CCRBooksTableViewController *booksViewController = (CCRBooksTableViewController *)segue.destinationViewController;
        booksViewController.publisher = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    }
}

#pragma mark - Core Data stack

- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - Notification handlers
- (void)updatePublishersTableView
{
    NSLog(@"Update Publishers table view iCloud notification");
    [self.tableView reloadData];
}

#pragma mark - NSObject
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
