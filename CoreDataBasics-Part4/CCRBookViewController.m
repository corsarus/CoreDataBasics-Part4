//
//  CCRBookViewController.m
//  CoreDataBasics-Part2
//
//  Created by Catalin (iMac) on 20/02/2015.
//  Copyright (c) 2015 corsarus. All rights reserved.
//

#import "CCRBookViewController.h"
#import "AppDelegate.h"

@interface CCRBookViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *pageCountField;
@property (weak, nonatomic) IBOutlet UITextField *publishDateField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation CCRBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.hidden = YES;
    
    // Become the text fields delegate to show / hide the date picker
    self.publishDateField.delegate = self;
    self.titleField.delegate = self;
    self.pageCountField.delegate = self;
    
    [self.datePicker addTarget:self action:@selector(updatePublishDate:) forControlEvents:UIControlEventValueChanged];
}

- (BOOL)prefersStatusBarHidden
{
    // Hide the status bar
    return YES;
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.publishDateField) {
        [self.titleField resignFirstResponder];
        [self.pageCountField resignFirstResponder];
        self.datePicker.hidden = NO;
        return NO;
    } else {
        self.datePicker.hidden = YES;
    }
    
    return YES;
}

#pragma mark - Actions

- (void)updatePublishDate:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd/YYYY";

    self.publishDateField.text = [dateFormatter stringFromDate:self.datePicker.date];
}

- (IBAction)cancelCreation:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createBookAndClose:(id)sender {
    
    if (self.titleField.text.length > 0) {
        NSEntityDescription *bookEntityDescription = [NSEntityDescription entityForName:@"Book" inManagedObjectContext:[self appDelegate].managedObjectContext];
        
        NSManagedObject *bookManagedObject = [[NSManagedObject alloc] initWithEntity:bookEntityDescription insertIntoManagedObjectContext:[self appDelegate].managedObjectContext];
        [bookManagedObject setValue:self.titleField.text forKey:@"title"];
        [bookManagedObject setValue:[NSNumber numberWithInteger:[self.pageCountField.text integerValue] ] forKey:@"pageCount"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *publishDate = [formatter dateFromString:self.publishDateField.text];
        [bookManagedObject setValue:publishDate forKey:@"datePublished"];
        
        [bookManagedObject setValue:self.publisher forKey:@"publisher"];
        
        [[self appDelegate] saveContext];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Core Data stack

- (AppDelegate *)appDelegate
{
    return [UIApplication sharedApplication].delegate;
}
@end
