//
//  IoTHubFIleUploader.h
//  IoTHubImageUploader
//
//  Created by Vineeth on 19/06/19.
//  Copyright © 2019 Vineeth. All rights reserved.
//

#import <Foundation/Foundation.h>
// Protocol definition starts here
@protocol IoTHubFIleUploadDelegate <NSObject>
@required
-(void)OnFileUploadStatus:(long)status;
-(void)OnFileUploadCompletion:(NSString*)fileName;
-(void)OnFileUploadError:(NSString*)fileName;
@end

@interface IoTHubFIleUploader : NSObject
{
    id <IoTHubFIleUploadDelegate> _delegate;
}
@property (nonatomic,strong) id delegate;

-(void)uploadData:(NSData*)data iotHubConnectionString:(NSString*)connectionString filenameToUpLoad:(NSString*)fileName;
-(void)stopUploading;
@end
// Delegate to respond back
