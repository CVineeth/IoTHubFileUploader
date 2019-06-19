//
//  IoTHubFIleUploader.m
//  IoTHubImageUploader
//
//  Created by Vineeth on 19/06/19.
//  Copyright © 2019 Vineeth. All rights reserved.
//

#import "IoTHubFIleUploader.h"

//#import "AzureIoTHubClient/iothub_client.h"
//#include "azure_c_shared_utility/shared_util_options.h"
#include "iothubtransporthttp.h" //http
#include "iothubtransportmqtt.h" //mqtt

static long bytedatasize        = 0;
static long block_count         = 0;
static unsigned char* buffer    = NULL;
static long totalSize           = 0;
static long remaining           = 0;
static bool uploadStatus        = true;

@implementation IoTHubFIleUploader

static IOTHUB_CLIENT_FILE_UPLOAD_GET_DATA_RESULT getDataCallback(IOTHUB_CLIENT_FILE_UPLOAD_RESULT result, unsigned char const** data, size_t* size, void* context)
{
    IOTHUB_CLIENT_FILE_UPLOAD_GET_DATA_RESULT returnArg = IOTHUB_CLIENT_FILE_UPLOAD_GET_DATA_OK;
    if(!uploadStatus)
    {
        returnArg = IOTHUB_CLIENT_FILE_UPLOAD_GET_DATA_ABORT;
    }
    else
    {
        long blocks_to_send = 500000;
        if (result == FILE_UPLOAD_OK)
        {
            if (data != NULL && size != NULL)
            {
                if (block_count < totalSize)
                {
                    *data = (const unsigned char*)buffer + block_count;
                    if (blocks_to_send > remaining)
                    {
                        blocks_to_send = remaining;
                    }
                    *size = blocks_to_send;
                    block_count += blocks_to_send;
                    remaining -= blocks_to_send;
                    long status = (block_count*100)/totalSize;
                    NSLog(@"%ld%@ is completed\n ",status,@"%");
                    [(__bridge id)context uploadStatus:status];
                }
                else
                {
                    *data = NULL;
                    *size = 0;
                }
            }
        }
        else
        {
            [(__bridge id)context hardStopUploading];
            fprintf(stderr, "Received unexpected result %s", ENUM_TO_STRING(IOTHUB_CLIENT_FILE_UPLOAD_RESULT, result));
            returnArg = IOTHUB_CLIENT_FILE_UPLOAD_GET_DATA_ABORT;
        }
    }
    return returnArg;
}

-(void)hardStopUploading
{
    if (_delegate && [_delegate respondsToSelector:@selector(OnFileUploadError:)])
    {
        [_delegate OnFileUploadError:@""];
    }
}

- (void)uploadStatus:(long)status
{
    if (_delegate && [_delegate respondsToSelector:@selector(OnFileUploadStatus:)])
    {
        [_delegate OnFileUploadStatus:status];
    }
}

-(void)uploadData:(NSData*)data iotHubConnectionString:(NSString*)connectionString filenameToUpLoad:(NSString*)fileName
{
    uploadStatus = true;
    IOTHUB_CLIENT_LL_HANDLE iotblob_ll_handle;
    if ((iotblob_ll_handle = IoTHubClient_LL_CreateFromConnectionString(connectionString.UTF8String, MQTT_Protocol)) == NULL)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(OnFileUploadError:)]) {
            [_delegate OnFileUploadError:@"ERROR: iotHubClientHandle is NULL"];
        }
    }
    else
    {
        time_t start = time(NULL);
        const char* pFileName = [fileName UTF8String];
        if( buffer )
        {
            free(buffer);
            buffer = NULL;
        }
        
        buffer = malloc(data.length);
        memcpy(buffer, [data bytes], data.length);
        bytedatasize = data.length;
        
        if (buffer != NULL) {
            block_count = 0;
            totalSize = sizeof(unsigned char) * bytedatasize;
            remaining = sizeof(unsigned char) * bytedatasize;
 
            IOTHUB_CLIENT_RESULT result = IoTHubClient_LL_UploadMultipleBlocksToBlobEx(iotblob_ll_handle, pFileName, getDataCallback, (__bridge void *)(self));
            if(!uploadStatus)
            {
                if (_delegate && [_delegate respondsToSelector:@selector(OnFileUploadError:)])
                {
                    [_delegate OnFileUploadError:@"Upload to blob has been aborted by the user"];
                }
            }
            else
            {
                NSString* errorText = nil;
                switch (result) {
                    case IOTHUB_CLIENT_OK:
                    {
                        break;
                    }
                    case IOTHUB_CLIENT_INVALID_ARG:
                    {
                        errorText = [NSString stringWithFormat:@"Failed to upload: %@",fileName];
                        break;
                    }
                    case IOTHUB_CLIENT_ERROR:
                    {
                        errorText = [NSString stringWithFormat:@"Failed to upload: %@",fileName];
                        break;
                    }
                    case IOTHUB_CLIENT_INVALID_SIZE:
                    {
                        errorText = [NSString stringWithFormat:@"Failed to upload: %@",fileName];
                        break;
                    }
                    case IOTHUB_CLIENT_INDEFINITE_TIME:
                    {
                        errorText = [NSString stringWithFormat:@"Failed to upload: %@",fileName];
                        break;
                    }
                    default:
                        errorText = [NSString stringWithFormat:@"Failed to upload: %@",fileName];
                        break;
                }
                if(nil != errorText && [errorText length] > 0)
                {
                    if (_delegate && [_delegate respondsToSelector:@selector(OnFileUploadError:)])
                    {
                        [_delegate OnFileUploadError:errorText];
                    }
                }
                else
                {
                    printf("Uploaded: %s\n", pFileName);
                    if (_delegate && [_delegate respondsToSelector:@selector(OnFileUploadCompletion:)])
                    {
                        [_delegate OnFileUploadCompletion:fileName];
                    }
                }
            }
            free(buffer);
            buffer = NULL;
        }
        time_t end = time(NULL);
        printf("Elapsed time in seconds: %ld", (end - start));
        IoTHubClient_LL_Destroy(iotblob_ll_handle);
    }
}

-(void)stopUploading
{
    uploadStatus = false;
}
@end
