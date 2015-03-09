//
//  Publisher.m
//  CoreDataBasics-Part3
//
//  Created by Catalin (iMac) on 20/02/2015.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import "Publisher.h"


@implementation Publisher

@dynamic name;
@dynamic firstLetter;
@dynamic books;

- (NSString *)firstLetter
{
    return [self.name substringWithRange:NSMakeRange(0, 1)];
}

- (BOOL)validateForInsert:(NSError *__autoreleasing *)error
{
    if (![super validateForInsert:error])
        return NO;
    
    // If there already is a Publisher with the same name, reject insertion
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", self.name];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:self.entity.name];
    fetchRequest.predicate = predicate;
    
    NSError *fetchError = nil;
    NSUInteger existingObjectsCount = [self.managedObjectContext countForFetchRequest:fetchRequest error:&fetchError];
    
    return existingObjectsCount == 1;
}

@end
