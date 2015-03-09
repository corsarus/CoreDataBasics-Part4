//
//  CCRBooksTableViewController.h
//  CoreDataBasics-Part2
//
//  Created by Catalin (iMac) on 20/02/2015.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CCRBooksTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObject *publisher;

@end
