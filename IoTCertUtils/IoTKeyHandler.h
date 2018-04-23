//
//  IoTKeyHandler.h
//  IoTCertUtils
//
//  Created by david5_huang on 2018/4/20.
//  Copyright © 2018年 david5_huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/bio.h>
#import <openssl/x509.h>
#import <openssl/pem.h>
#import <openssl/pkcs12.h>
#import <openssl/opensslv.h>
#import <openssl/evp.h>

@interface IoTKeyHandler : NSObject

extern NSString *const P12Pass;

- (void)createP12:(NSString *)certId:(NSString *)certPem:(NSString *)pk;

- (void)createP12File:(NSString *)fileName:(PKCS12 *)p12;
- (NSString *)p12FilePath:(NSString *)fileName;

- (NSData *)createP12Data:(NSString *)certPem:(NSString *)pk;

- (BOOL)isKeyExist:(NSString *)certId;

@end
