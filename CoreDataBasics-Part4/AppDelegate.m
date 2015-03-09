//
//  AppDelegate.m
//  CoreDataBasics-Part2
//
//  Created by admin on 10/02/15.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Copy the pre-populated database files to the app's Documents directory
    NSString *persistentStorePath = [self.applicationDocumentsDirectory.path stringByAppendingPathComponent:@"Library.sqlite"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:persistentStorePath]) {
        NSString *databasePath = [[NSBundle mainBundle] pathForResource:@"Library" ofType:@"sqlite"];
        NSError *error = nil;
        [fileManager copyItemAtPath:databasePath toPath:persistentStorePath error:&error];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Library" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    
    if (cloudURL)
    {
        NSDictionary *standardOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                         [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                         nil];
        
        NSDictionary *cloudOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                      [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                      @"LibraryStore", NSPersistentStoreUbiquitousContentNameKey,
                                      cloudURL, NSPersistentStoreUbiquitousContentURLKey,
                                      nil];
        
        [self.persistentStoreCoordinator performBlockAndWait:^{
            
            NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            NSURL *cloudStoreURL = [documentsDirectory URLByAppendingPathComponent:@"CloudLibrary.sqlite"];
            NSURL *localStoreURL = [documentsDirectory URLByAppendingPathComponent:@"Library.sqlite"];
            
            // If the flag file exists, it means the local database was already migrated to iCloud (on the current device or another one), so we don't have to migrate again
            NSURL *flagFileCloudURL = [cloudURL URLByAppendingPathComponent:@"flag"];
            NSError *error = nil;
            if (![fileManager startDownloadingUbiquitousItemAtURL:flagFileCloudURL error:&error]) {
                 NSURL *flagFileLocalURL = [documentsDirectory URLByAppendingPathComponent:@"flag"];
                if ([fileManager createFileAtPath:flagFileLocalURL.path contents:[@"FLAG" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]) {
                    [fileManager setUbiquitous:YES itemAtURL:flagFileLocalURL destinationURL:flagFileCloudURL error:&error];
                }
                
                if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:localStoreURL options:standardOptions error:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                } else {
                    NSPersistentStore *localPersistentStore = [_persistentStoreCoordinator persistentStoreForURL:localStoreURL];
                    [_persistentStoreCoordinator migratePersistentStore:localPersistentStore toURL:cloudStoreURL options:cloudOptions withType:NSSQLiteStoreType error:&error];
                }
            } else {
                if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:cloudStoreURL options:cloudOptions error:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                }
            }
            
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            
            [notificationCenter addObserver:self
                                   selector:@selector(processStoresWillChange:)
                                       name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                                     object:_persistentStoreCoordinator];
            
            [notificationCenter addObserver:self
                                   selector:@selector(processStoresDidChange:)
                                       name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                                     object:_persistentStoreCoordinator];
            
            [notificationCenter addObserver:self
                                   selector:@selector(processContentChanges:)
                                       name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                     object:_persistentStoreCoordinator];
            
        }];
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - iCloud notification handlers

- (void)processStoresWillChange:(NSNotification *)notification
{
    // Save pending changes in the managed object context
    [self.managedObjectContext performBlockAndWait:^{
        
        if ([self.managedObjectContext hasChanges]) {
            [self saveContext];
        }
        
        [self.managedObjectContext reset];
    }];
}

- (void)processStoresDidChange:(NSNotification *)notification
{
    // Post notification to trigger UI updates
    [[NSNotificationCenter defaultCenter] postNotificationName:CDUpdateUINotification object:self.managedObjectContext];
}

- (void)processContentChanges:(NSNotification *)notification
{
    [self.managedObjectContext performBlock:^{
        // Merge incoming data updates in the managed object context
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        
        // Post notification to trigger UI updates
        [[NSNotificationCenter defaultCenter] postNotificationName:CDUpdateUINotification object:self.managedObjectContext];
    }];
}

#pragma mark - Utility methods
- (BOOL)fileWithName:(NSString *)fileName existsInDirectoryForPath:(NSString *)directoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *subpaths = [fileManager subpathsOfDirectoryAtPath:directoryPath error:&error];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH[c] %@", fileName];
    NSArray *filteredSubpaths = [subpaths filteredArrayUsingPredicate:predicate];
    return filteredSubpaths.count != 0;
}

- (void)removeExistingObjectsFromChangeNotification:(NSNotification *)notification
{
    NSArray *objectsToBeInserted = [notification.userInfo objectForKey:NSInsertedObjectsKey];
    NSMutableArray *objectToInsert = [[NSMutableArray alloc] init];
    
    [objectsToBeInserted enumerateObjectsUsingBlock:^(NSManagedObjectID *obj, NSUInteger idx, BOOL *stop) {
        NSEntityDescription *entityDescription = obj.entity;
        if ([entityDescription.name isEqualToString:@"Publisher"]) {
            [self removeDuplicateForManagedObjectID:obj keyAttributeNames:@[@"name"]];
            
        } else if ([entityDescription.name isEqualToString:@"Book"]) {
            [self removeDuplicateForManagedObjectID:obj keyAttributeNames:@[@"title"]];
        } else if ([entityDescription.name isEqualToString:@"Author"]) {
            [self removeDuplicateForManagedObjectID:obj keyAttributeNames:@[@"firstName", @"lastName"]];
        } else if ([entityDescription.name isEqualToString:@"Address"]) {
            [self removeDuplicateForManagedObjectID:obj keyAttributeNames:@[@"postalCode"]];
        }
        
    }];
    
    [notification.userInfo setValue:objectToInsert forKey:NSInsertedObjectsKey];
}

- (BOOL)managedObjectExistsForEntityName:(NSString *)entityName attributeName:(NSString *)attributeName attributeValue:(id)attributeValue
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", attributeName, attributeValue];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = predicate;

    NSError *error = nil;
    NSUInteger existingObjectsCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
    
    BOOL result = error == nil && existingObjectsCount == 0;
    
    return result;
}

- (void)removeDuplicateForManagedObjectID:(NSManagedObjectID *)objectID keyAttributeNames:(NSArray *)attributeNames
{
    NSManagedObject *objectToKeep = [self.managedObjectContext objectWithID:objectID];
    
    if (objectToKeep) {
        __block NSMutableArray *predicates = [[NSMutableArray alloc] init];
        
        [attributeNames enumerateObjectsUsingBlock:^(NSString *attributeName, NSUInteger idx, BOOL *stop) {
            id valueToCompare = [objectToKeep valueForKey:attributeName];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", attributeName, valueToCompare];
            
            [predicates addObject:predicate];
        }];
        
        NSCompoundPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:objectToKeep.entity.name];
        fetchRequest.predicate = compoundPredicate;
        
        NSError *error = nil;
        NSArray *existingObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        __block contextChanged = NO;
        
        [existingObjects enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
            if (obj != objectToKeep) {
                [self.managedObjectContext deleteObject:obj];
                contextChanged = YES;
            }
        }];
        
//        if (contextChanged)
//            [self.managedObjectContext save:nil];
    }
    
}

@end
