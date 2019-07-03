# IoTHubFileUploader
# Use the Azure IoT Hub File Upload API with Objective C and Azure IoT C SDK - (iOS & Mac OS X).  
This is an Objective C wrapper class "IoTHubFIleUploader" at path "IoTHubFileUpload/FileUploader/" to upload a file to Azure blob via IoTHub. Which can be used to write device client in iOS and Mac OS X using Objective C and Swift.  
# Prerequisites
1.Azure IoTHub which should associated with an Azure Storage account. (https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-csharp-csharp-file-upload).   
2. The latest version of XCode, running the latest version of the iOS SDK. This sample was tested with XCode 9.4 and iOS 11.4.  
3. The latest version of CocoaPods.  
# Usage
Create a iOS/Mac OS X project and configure the same with the following libraries using cocopod.  
Add the files "IoTHubFIleUploader.h", "IoTHubFIleUploader.m" from "IoTHubFileUpload/FileUploader/" to the project.  
CocoaPods  
AzureIoTHubClient contains the Azure IoT Hub Client  
AzureIoTHubServiceClient contains the Azure IoT Hub Service Client  
AzureIoTUtility contains the Azure IoT C Shared Utility library  
AzureIoTuAmqp contains the Azure IoT AMQP library  
AzureIoTuMqtt contains the Azure IoT MQTT library  
Instantiate the IoTHubFIleUploader and call the method "uploadData:iotHubConnectionString:filenameToUpLoad"  

Please see the sample project for detailed usage.
