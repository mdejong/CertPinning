//
//  ViewController.m
//  CertPinning
//
//  Created by Mo DeJong on 1/3/17.
//  Copyright © 2017 HelpURock. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UITextField *textFieldURL;

@property (nonatomic, retain) IBOutlet UILabel *outputLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  NSAssert(self.textFieldURL, @"textField");
  NSAssert(self.outputLabel, @"outputLabel");
  
  self.textFieldURL.text = @"URL";
  self.outputLabel.text = @"  Label Text";
  
  self.textFieldURL.delegate = self;
}

- (void) dealloc {
  self.textFieldURL.delegate = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate

// Implement UITextFieldDelegate protocol

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
  NSLog(@"URL TEXT INPUT: \"%@\"", textField.text);
  
  BOOL didResign = [textField resignFirstResponder];
  
  //[self startDownload:textField.text];
  
  return didResign;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self.textFieldURL resignFirstResponder];
}

@end
