//
//  ViewController.m
//  CertPinning
//
//  Created by Mo DeJong on 1/3/17.
//  Copyright © 2017 HelpURock. All rights reserved.
//

#import "ViewController.h"

#import "AFNetworking.h"

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
  
  // HTTPS over TLS is the default in iOS 10.X
  
  //self.textFieldURL.text = @"http://developers.google.com/identity/sign-in/ios";

  // Fails because of TLS requirements
  
  self.textFieldURL.text = @"http://www.javatpoint.com/http-session-in-session-tracking";
  
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
  
  [self startDownload:textField.text];
  
  return didResign;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self.textFieldURL resignFirstResponder];
}

// Invoked as a result of UI action, starts download fron the given URL

- (void) startDownload:(NSString*)urlStr
{
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
  
  NSString *formattedURLStr = [NSString stringWithFormat:@"%@", urlStr];

  NSURL *URL = [NSURL URLWithString:formattedURLStr];
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  
  NSLog(@"URL GET \"%@\"", request);
  
  NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
  } completionHandler:^(NSURLResponse *response, NSURL *filePathURL, NSError *error) {
    if (error != nil) {
      NSLog(@"could not download: %@", error);
      self.outputLabel.text = [NSString stringWithFormat:@"  %@", [error description]];
    } else {
      NSLog(@"File downloaded to: %@", filePathURL);
      NSString *filePath = [filePathURL path];
      NSStringEncoding enc;
      NSString *fileDataStr = [NSString stringWithContentsOfFile:filePath usedEncoding:&enc error:nil];
      assert(NSUTF8StringEncoding == enc);
      self.outputLabel.text = [NSString stringWithFormat:@"  %@", fileDataStr];
    }
  }];
  
  [downloadTask resume];
}

@end
