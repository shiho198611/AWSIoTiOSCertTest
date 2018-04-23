//
//  IoTMqttService.m
//  IoTCertUtils
//
//  Created by david5_huang on 2018/4/20.
//  Copyright © 2018年 david5_huang. All rights reserved.
//

#import "IoTMqttService.h"

@implementation IoTMqttService

+ (instancetype) sharedInstance{
    static IoTMqttService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[IoTMqttService alloc] init];
    });
    return instance;
}

- (void)connectToMqttClient:(NSString *)endpoint:(NSString *)certId:(NSString *)certPem:(NSString *)privateKey completion:(void (^)(AWSIoTMQTTStatus status))callback{
    
    IoTKeyHandler *keyHandler = [[IoTKeyHandler alloc] init];
    if(![keyHandler isKeyExist:certId]){
        NSLog(@"-----connectToMqttClient, key not exist-----");
        [keyHandler createP12:certId :certPem :privateKey];
    }
    else{
        NSLog(@"-----connectToMqttClient, key file exist-----");
    }
    
    NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:[keyHandler p12FilePath:certId]];
    NSData *data = [[NSData alloc] initWithContentsOfURL:fileUrl];
    
    if([AWSIoTManager importIdentityFromPKCS12Data:data passPhrase:P12Pass certificateId:certId]){
        
        NSString *uuid = [[NSUUID UUID] UUIDString];
        AWSEndpoint *iotEndpoint = [[AWSEndpoint alloc] initWithURLString:endpoint];
        
        AWSServiceConfiguration *iotDataConfig = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 endpoint:iotEndpoint credentialsProvider:nil];
        
        [AWSIoTDataManager registerIoTDataManagerWithConfiguration:iotDataConfig forKey:@"IoTCertTest"];
        iotDataManager = [AWSIoTDataManager IoTDataManagerForKey:@"IoTCertTest"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [iotDataManager connectWithClientId:uuid cleanSession:TRUE certificateId:certId statusCallback:^(AWSIoTMQTTStatus status) {
                if(status == AWSIoTMQTTStatusConnected){
                    isMqttConnected = TRUE;
                }
                else{
                    isMqttConnected = FALSE;
                }
                callback(status);
            }];
            
        });
        
    }
    else{
        NSLog(@"-----connectToMqttClient, key error-----");
    }
}

- (void)disconnectMqttClient{
    if(isMqttConnected && iotDataManager != nil){
        [iotDataManager disconnect];
    }
}

- (void)subscribeShadowTopic:(NSString *)shadowTopic
                         QoS:(AWSIoTMQTTQoS)qos
                  completion:(void (^)(NSString *))callback{
    if(isMqttConnected){
        [iotDataManager subscribeToTopic:shadowTopic QoS:qos messageCallback:^(NSData * _Nonnull data) {
            NSString* shadowStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(shadowStr);
        }];
    }
}

- (void)publishShadowDoc:(NSString *)shadowJson
                   topic:(NSString *)shadowTopic
                     QoS:(AWSIoTMQTTQoS)qos{
    if(isMqttConnected){
//        [iotDataManager publishData:shadowJson onTopic:shadowTopic QoS:qos];
        [iotDataManager publishString:shadowJson onTopic:shadowTopic QoS:qos];
    }
}

@end
