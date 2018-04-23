//
//  IoTMqttService.h
//  IoTCertUtils
//
//  Created by david5_huang on 2018/4/20.
//  Copyright © 2018年 david5_huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSIoTManager.h"
#import "IoTKeyHandler.h"
#import "AWSIoTDataManager.h"

@interface IoTMqttService : NSObject {
    AWSIoTDataManager *iotDataManager;
    BOOL isMqttConnected;
}

+ (instancetype) sharedInstance;

- (void)connectToMqttClient:(NSString *)endpoint:(NSString *)certId:(NSString *)certPem:(NSString *)privateKey completion:(void (^)(AWSIoTMQTTStatus status))callback;

- (void)disconnectMqttClient;

- (void)subscribeShadowTopic:(NSString *)shadowTopic
                         QoS:(AWSIoTMQTTQoS)qos
                  completion:(void (^)(NSString *))callback;

- (void)publishShadowDoc:(NSString *)shadowJson
                   topic:(NSString *)shadowTopic
                     QoS:(AWSIoTMQTTQoS)qos;

@end
