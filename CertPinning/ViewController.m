//
//  ViewController.m
//  CertPinning
//
//  Created by Mo DeJong on 1/3/17.
//  Copyright © 2017 HelpURock. All rights reserved.
//

#import "ViewController.h"

#import "AsyncURLDownloader.h"

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UITextField *textFieldURL;

@property (nonatomic, retain) IBOutlet UILabel *outputLabel;

@property (atomic, copy) NSString *downloadStr;

@property (nonatomic, retain) AsyncURLDownloader *downloader;

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
  
  if (self.downloader != nil) {
    [self.downloader cancelDownload];
    self.downloader = nil;
  }
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
  NSURL *url = [NSURL URLWithString:urlStr];
 
  AsyncURLDownloader *downloader = [AsyncURLDownloader asyncURLDownloaderWithURL:url];
  
  self.downloader = downloader;
  
  // Register for notification when URL download is finished
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(asyncURLDownloaderDidFinishNotification:)
                                               name:AsyncURLDownloadDidFinish
                                             object:self.downloader];
  
  [downloader startDownload];
}

// Invoked when URL has been fully downloaded

- (void) asyncURLDownloaderDidFinishNotification:(NSNotification*)notification
{
  NSAssert(self.downloader != nil, @"downloader is nil");
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:AsyncURLDownloadDidFinish object:self.downloader];
  
  int httpStatusCode = self.downloader.httpStatusCode;
  NSAssert(httpStatusCode > 0, @"httpStatusCode is invalid");
  
  NSData *downloadedData = nil;
  
  NSString *formattedStr = @"";
  
  if (httpStatusCode == 200) {
    // Downloaded data from the network, test it to see if this is a PNG file, then check that it is APNG
    NSLog(@"HTTP 200");
    
    downloadedData = [[notification userInfo] objectForKey:@"DATA"];
    
    NSString *contentsStr = [[NSString alloc] initWithData:downloadedData encoding:NSUTF8StringEncoding];
    
    NSLog(@"contents:");
    NSLog(@"%@", contentsStr);
    
    formattedStr = contentsStr;
  } else {
    formattedStr = [NSString stringWithFormat:@"HTTP status code %d", httpStatusCode];
    NSLog(@"%@", formattedStr);
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    assert([NSThread isMainThread] == TRUE);
    self.downloadStr = formattedStr;
    self.outputLabel.text = formattedStr;
  });
  
  self.downloader = nil;
  
  return;
}

@end
