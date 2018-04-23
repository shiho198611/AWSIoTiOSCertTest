//
//  IoTKeyHandler.m
//  IoTCertUtils
//
//  Created by david5_huang on 2018/4/20.
//  Copyright © 2018年 david5_huang. All rights reserved.
//

#import "IoTKeyHandler.h"

@implementation IoTKeyHandler

NSString *const P12Pass = @"iotcerttest_iot_pass";

- (void)createP12:(NSString *)certId:(NSString *)certPem:(NSString *)pk{
    
    const char *certChars = [certPem cStringUsingEncoding:NSUTF8StringEncoding];
    
    BIO *buffer = BIO_new(BIO_s_mem());
    BIO_puts(buffer, certChars);
    
    X509 *cert;
    cert = PEM_read_bio_X509(buffer, NULL, 0, NULL);
    
    X509_print_fp(stdout, cert);
    
    BIO *publicBIO = NULL;
    EVP_PKEY *pKey = NULL;
    NSData *pkData = [pk dataUsingEncoding:NSUTF8StringEncoding];
    if((publicBIO = BIO_new_mem_buf((unsigned char *)[pkData bytes], [pkData length])) == NO){
        NSLog(@"BIO_new_mem_buf() failed!");
    }
    pKey = PEM_read_bio_PrivateKey(publicBIO, NULL, NULL, NULL);
    
    if(!X509_check_private_key(cert, pKey)){
        NSLog(@"private key error.");
    }
    
    PKCS12 *p12;
    SSLeay_add_all_algorithms();
    ERR_load_CRYPTO_strings();
    
    p12 = PKCS12_create("iotcerttest_iot_pass", "iOSMobileCertficate", pKey, cert, NULL, 0, 0, 0, 0, 0);
    
    if(!p12) {
        fprintf(stderr, "Error creating PKCS#12 structure\n");
        return;
    }
    
    [self createP12File:certId:p12];
}

- (void)createP12File:(NSString *)fileName:(PKCS12 *)p12{
    NSString *p12FilePath = [self p12FilePath:fileName];
    if (![[NSFileManager defaultManager] createFileAtPath:p12FilePath contents:nil attributes:nil]) {
        NSLog(@"Error creating file for P12");
        @throw [[NSException alloc] initWithName:@"Fail getP12File" reason:@"Fail Error creating file for P12" userInfo:nil];
    }
    
    //get a FILE struct for the P12 file
    NSFileHandle *outputFileHandle = [NSFileHandle fileHandleForWritingAtPath:p12FilePath];
    FILE *p12File = fdopen([outputFileHandle fileDescriptor], "w");
    
    i2d_PKCS12_fp(p12File, p12);
    PKCS12_free(p12);
    fclose(p12File);
    
    NSLog(@"create key end.");
}

- (NSString *)p12FilePath:(NSString *)fileName{
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *p12FileName = [fileName stringByAppendingString:@".p12"];
    
    return [documentsFolder stringByAppendingPathComponent:p12FileName];
}

- (BOOL)isKeyExist:(NSString *)certId{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *keyFilePath = [self p12FilePath:certId];
    return [fileManager fileExistsAtPath:keyFilePath];
}


@end
