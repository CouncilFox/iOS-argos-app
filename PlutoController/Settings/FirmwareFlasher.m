//
//  FirmwareFlasher.m
//  PlutoController
//
//  Created by Drona Aviation on 12/09/18.
//  Copyright © 2018 Drona Aviation. All rights reserved.
//

#import "Config.h"
#import "Util.h"
#import "HexParser.h"
#import "BlockObjectList.h"
#import "FirmwareProgressDialogView.h"
#import "FirmwareDownloadDialogView.h"
#import "MBProgressHUD.h"
#import "CustomProgressView.h"
#import "FirmwareFlasher.h"

@interface FirmwareFlasher () <UIDocumentMenuDelegate, UIDocumentPickerDelegate, NSURLSessionDataDelegate>

@property (weak, nonatomic) IBOutlet UIView *swipeView;
@property (weak, nonatomic) IBOutlet UIButton *btnBrowse;
@property (weak, nonatomic) IBOutlet UIButton *btnFlash;
@property (weak, nonatomic) IBOutlet UIButton *btnDownload;
@property (weak, nonatomic) IBOutlet UILabel *labelFileName;
@property (strong, nonatomic) MBProgressHUD *hud;

@end

FirmwareProgressDialogView *firmwareProgressDialogView;
FirmwareDownloadDialogView *firmwareDownloadDialogView;
NSString *downloadFileName;

@implementation FirmwareFlasher

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
    [_swipeView addGestureRecognizer:swipeRight];
    
    _btnBrowse.layer.cornerRadius = 20;
    _btnBrowse.clipsToBounds = YES;
    [_btnBrowse.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnBrowse layer] setBorderWidth:5.0f];
    [_btnBrowse setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    _btnFlash.layer.cornerRadius = 20;
    _btnFlash.clipsToBounds = YES;
    [_btnFlash.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnFlash layer] setBorderWidth:5.0f];
    [_btnFlash setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    _btnFlash.alpha = 0.5f;
    _btnFlash.userInteractionEnabled = NO;
    
    _btnDownload.layer.cornerRadius = 20;
    _btnDownload.clipsToBounds = YES;
    [_btnDownload.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [[_btnDownload layer] setBorderWidth:5.0f];
    [_btnDownload setTitleColor:[UIColor colorWithRed:18.0f/255.0f green:186.0f/255.0f blue:144.0f/255.0f alpha:1.0f] forState:UIControlStateSelected];
    
    //downloadFileName = @"Magis-v3R";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated {
    [plutoManager.protocol setInputStreamDelegate];
    if(nil != firmwareProgressDialogView)
        [firmwareProgressDialogView closeFirmwareProgressDialog];
}

- (IBAction)BackToController:(id)sender {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)swipeRight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (IBAction)firmareSelect:(id)sender {
    
    UIDocumentMenuViewController *importMenu =
    [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                         inMode:UIDocumentPickerModeImport];
    
    UIPopoverPresentationController *popPresenter = [importMenu
                                                     popoverPresentationController];
    popPresenter.sourceView = self.view;
    popPresenter.sourceRect = CGRectMake(self.view.bounds.size.width * 0.5f, self.view.bounds.size.height * 0.5f, 0, 0);
    
    importMenu.delegate = self;
    [self presentViewController:importMenu animated:YES completion:nil];
}

- (IBAction)firmareDownload:(id)sender {
//    firmwareDownloadDialogView = [[FirmwareDownloadDialogView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    [firmwareDownloadDialogView setFirmwareViewController: self];
//
//    [self.view addSubview: firmwareDownloadDialogView];
    
    [self downloadFirmware:@"https://www.dronaaviation.com/wp-content/uploads/hex/PlutoX_Magis_2_0_0.hex" and:@"MAGISX-RAVENONE"];
    
}

- (IBAction)firmareFlash:(id)sender {
    if (plutoManager.WiFiConnection.connected) {
        
        if(![Util isConnectedToPlutoWifi]) {
            
            UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:@"Detach camera and connect to drone Wifi to flash the firmware" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertDialog addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [alertDialog dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alertDialog animated:YES completion:nil];
            
        } else {
            
            firmwareProgressDialogView = [[FirmwareProgressDialogView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            
            [(CustomProgressView *)firmwareProgressDialogView.firmwareProgressView setGradient];
            
            [firmwareProgressDialogView setBlockObjectList: [blockObjectList mutableCopy]];
            [firmwareProgressDialogView setViewController: self];
            [self.view addSubview: firmwareProgressDialogView];
        }
        
    } else {
        [self.view makeToast:@"Raven is not connected"];
    }
}

-(void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker {
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (controller.documentPickerMode == UIDocumentPickerModeImport) {
        NSString* fileContents = [NSString stringWithContentsOfURL: url
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
        NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];
        NSLog(@"Lines size: %lu", (unsigned long)lines.count);
        
        [_labelFileName setText:[[url absoluteString] lastPathComponent]];
        
        HexParser *hexParser = [[HexParser alloc] init];
        blockObjectList = [hexParser readHexFile:[lines mutableCopy]];
        
        if([hexParser isValidHexFile]) {
            _btnFlash.alpha = 1.0f;
            _btnFlash.userInteractionEnabled = YES;
        } else {
            _btnFlash.alpha = 0.5f;
            _btnFlash.userInteractionEnabled = NO;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"file length: %lld", [response expectedContentLength]);
    fileLength = [response expectedContentLength];
    
    fileData = [[NSMutableData alloc]init];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(nonnull NSError *)error
{
    
    if(nil != _hud)
        [_hud hideAnimated:YES];
    
    [self.view makeToast:@"Failed to download. Check your internet connection."];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [fileData appendData:data];
    
    NSString *strData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"receive data: %@", strData);
    
    NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:[fileData length]];
    _hud.progress = [resourceLength floatValue] / fileLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_hud hideAnimated:YES];
    
    NSURL *tempURL = [NSFileManager.defaultManager.temporaryDirectory URLByAppendingPathComponent: downloadFileName];
    [fileData writeToFile:[tempURL path] atomically:YES];
    
    UIActivityViewController* activityViewController =[[UIActivityViewController alloc] initWithActivityItems:@[tempURL] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeMessage];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

-(void) downloadFirmware: (NSString *) downloadURL and: (NSString *) fileName {
    self->_hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self->_hud.mode= MBProgressHUDModeDeterminateHorizontalBar;
    
    self->_hud.label.text =@"Downloading...";
    
    downloadFileName = fileName;
    
    NSURL *url = [NSURL URLWithString:downloadURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES ];
    
    [connection start];
}

@end
