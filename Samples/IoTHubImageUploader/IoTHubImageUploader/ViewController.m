//
//  ViewController.m
//  IoTHubImageUploader
//
//  Created by Vineeth on 19/06/19.
//  Copyright © 2019 Vineeth. All rights reserved.
//

#import "ViewController.h"
#import "IoTHubFIleUploader.h"

static const char* connectionString = "--ConnectionString--";

@interface ViewController () <IoTHubFIleUploadDelegate>
{
    
}
@property (nonatomic,strong) IoTHubFIleUploader* fileUploader;
@property (weak, nonatomic) IBOutlet UILabel *statusDesLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _fileUploader = nil;
    _statusDesLabel.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onFileUploadStartAction:(id)sender {
    if( !_fileUploader )
    {
        NSString *stringPath = [[NSBundle mainBundle] pathForResource:@"lerone-pieters" ofType:@"png"];
        UIImage *pngImage = [[UIImage alloc] initWithContentsOfFile:stringPath];
        NSData * imageData = UIImagePNGRepresentation(pngImage);
        
        // creating unique file name to store in blob
        CFUUIDRef udid = CFUUIDCreate(NULL);
        NSString *udidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
        NSString* fileName = [NSString stringWithFormat:@"bsv/%@.png",udidString];
        
        _fileUploader = [[IoTHubFIleUploader alloc] init];
        _fileUploader.delegate = self;
        NSString* iothubConnectionurl = [NSString stringWithUTF8String:connectionString];
        
        dispatch_queue_t queue = dispatch_queue_create("com.yourdomain.yourappname", NULL);
        dispatch_async(queue, ^{
            [self->_fileUploader uploadData:imageData iotHubConnectionString:iothubConnectionurl filenameToUpLoad:fileName];
        });
    }
}

- (IBAction)onFileUploadStopAction:(id)sender {    
    [_fileUploader stopUploading];
}

/*
 *
 */
- (void) OnFileUploadStatus:(long)status {
    NSLog(@"OK");
    NSString* statusDes = [NSString stringWithFormat:@"%ld%@ is completed\n ", status, @"%"];

    dispatch_async( dispatch_get_main_queue(), ^{
        self.statusDesLabel.text = statusDes;
    });
}
-(void)OnFileUploadCompletion:(NSString*)fileName {
    _fileUploader = nil;
}

-(void)OnFileUploadError:(NSString*)fileName {
    _fileUploader = nil;
}
@end
