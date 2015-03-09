//
//  CCRBooksTableViewController.m
//  CoreDataBasics-Part2
//
//  Created by Catalin (iMac) on 20/02/2015.
//  Copyright (c) 2015 ÷. All rights reserved.
//

#import "CCRBooksTableViewController.h"
#import "CCRBookViewController.h"
#import "AppDelegate.h"

@interface CCRBooksTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CCRBooksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register for iCloud updates notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBooksTableView) name:CDUpdateUINotification object:nil];
    
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        
        NSEntityDescription *publisherEntityDescription = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:[self appDelegate].managedObjectContext];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"publisher = %@", self.publisher];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        fetchRequest.entity = publisherEntityDescription;
        fetchRequest.predicate = predicate;
        fetchRequest.sortDescriptors = @[sortDescriptor];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[self appDelegate].managedObjectContext
                                                                          sectionNameKeyPath:nil
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.fetchedResultsController.fetchedObjects.count;
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSManagedObject *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [book valueForKey:@"title"];
    
    NSManagedObject *author = [book valueForKey:@"author"];
    cell.detailTextLabel.text = [self fullNameForAuthor:author];
    
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show the Delete button when the table view cell is swiped left
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                                   title:@"Delete"
                                                                                handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                                                    
                                                                                    // Delete the managed object
                                                                                    NSManagedObject *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
                                                                                    [[self appDelegate].managedObjectContext deleteObject:book];
                                                                                    [[self appDelegate] saveContext];
                                                                                    
                                                                                }];
    
    deleteRowAction.backgroundColor = [UIColor redColor];
    
    return @[deleteRowAction];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Empty method. Necessary for the row actions to be displayed when the table view cells are swiped
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Enable the edit actions on the table view cells
    return YES;
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
            
            NSManagedObject *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = [book valueForKey:@"title"];
            
            NSManagedObject *author = [book valueForKey:@"author"];
            cell.detailTextLabel.text = [self fullNameForAuthor:author];
            
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

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addBook"]) {
        CCRBookViewController *newBookViewController = (CCRBookViewController *)segue.destinationViewController;
        newBookViewController.publisher = self.publisher;
    }
}

#pragma mark - Core Data stack

- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - Utility methods

- (NSString *)fullNameForAuthor:(NSManagedObject *)author
{
    NSString *firstName = [author valueForKey:@"firstName"];
    NSString *lastName = [author valueForKey:@"lastName"];

    NSString *authorName = nil;
    if (firstName && lastName)
        authorName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    else if (firstName)
        authorName = [firstName copy];
    else if (lastName)
        author = [lastName copy];
    
    return authorName;
}

#pragma mark - Notification handlers
- (void)updateBooksTableView
{
    NSLog(@"Update Books table view after iCloud notification");
    [self.tableView reloadData];
}

#pragma mark - NSObject
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
