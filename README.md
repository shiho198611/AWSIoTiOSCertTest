# AWSIoTiOSCertTest

This test showed how to connect AWS IoT with MQTT via IoT certificate.

Usually, connected to AWS IoT with MQTT via Cognito and IoT API to get access right and download certificate from AWS IoT service.

This iOS app is want to test below issue:

1. Connected to AWS IoT with MQTT by certificate and private key string.

2. Objective-C and swift bridge.

### Connected to AWS IoT

In this case, mobile client will get certificate and private key strings from custom IoT cloud service.

It will follow below steps in this test app:

1. Get certificate and private key strings.

2. Use those strings to creating a `PKCS12` format key, it will generated a `.p12` file(In iOS, create PKCS12 key by `OpenSSL-for-iOS` library).

3. Connecting to AWS IoT with MQTT.

4. When connecting raw value get "2", it means MQTT connected sucess.
