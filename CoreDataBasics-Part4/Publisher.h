//
//  Publisher.h
//  CoreDataBasics-Part3
//
//  Created by Catalin (iMac) on 20/02/2015.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Publisher : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * firstLetter;
@property (nonatomic, retain) NSSet *books;
@end

@interface Publisher (CoreDataGeneratedAccessors)

- (void)addBooksObject:(NSManagedObject *)value;
- (void)removeBooksObject:(NSManagedObject *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;

@end
