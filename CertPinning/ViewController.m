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

@property (atomic, copy) NSString *downloadStr;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  NSAssert(self.textFieldURL, @"textField");
  NSAssert(self.outputLabel, @"outputLabel");
  
  // HTTPS over TLS is the default in iOS 10.X
  
  self.textFieldURL.text = @"https://developers.google.com/identity/sign-in/ios";
  
  // HTTP connection fails by default until iOS 10.X due to TLS reqs
  
//  self.textFieldURL.text = @"http://developers.google.com/identity/sign-in/ios";
  
  self.outputLabel.text = @"  ";
  
//  self.outputLabel.lineBreakMode = NSLineBreakByWordWrapping;
  self.outputLabel.lineBreakMode = NSLineBreakByClipping;
  self.outputLabel.numberOfLines = 40;
  
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
  
  [self startDownload:textField.text];
  
  return didResign;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self.textFieldURL resignFirstResponder];
}

- (void) startDownload:(NSString*)urlStr
{
  NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *sessionWithoutADelegate = [NSURLSession sessionWithConfiguration:defaultConfiguration];
  
  NSURL *url = [NSURL URLWithString:urlStr];
  
  NSURLSessionDataTask *downloadTask = [sessionWithoutADelegate dataTaskWithURL:url
                                                                  completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
  {
    NSString *contentsStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSString *formattedStr;
    
    if (error != nil) {
      NSLog(@"could not download: %@", error);
      formattedStr = [NSString stringWithFormat:@"  %@", [error description]];
    } else {
      NSLog(@"download: %@", contentsStr);
      formattedStr = [NSString stringWithFormat:@"  %@", contentsStr];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      assert([NSThread isMainThread] == TRUE);
      self.downloadStr = formattedStr;
      self.outputLabel.text = formattedStr;
    });
  }
          ];
  
  [downloadTask resume];
}

@end
