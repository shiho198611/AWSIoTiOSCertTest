//
//  ViewController.swift
//  AWSIoTCertTest
//
//  Created by david5_huang on 2018/4/20.
//  Copyright © 2018年 david5_huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var connectMqtt: UIButton!
    
    @IBOutlet var shadowDocLabel: UILabel!
    
    @IBOutlet var publishShadow: UIButton!
    let mIoTKeyName:String = "iot_cert_test_key_name";
    let endpoint:String = "https://a3mo6d2s1bnb8v.iot.us-west-2.amazonaws.com/things/ios_iot_test/shadow";
    
    let updateAccept:String = "$aws/things/ios_iot_test/shadow/update/accepted";
    
    var isSubscribe:Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func actConnectMqtt(_ sender: Any) {
        
        IoTMqttService.sharedInstance().connect(toMqttClient: endpoint, mIoTKeyName, TestConst.iotCert, TestConst.iotPk, completion: {
            (status: AWSIoTMQTTStatus?) in

            print("connected status = \(status!.rawValue)");
            if(status!.rawValue == 2){
                IoTMqttService.sharedInstance().subscribeShadowTopic(self.updateAccept, qoS: AWSIoTMQTTQoS.messageDeliveryAttemptedAtMostOnce, completion: { (shadowDoc: String!) in
                    
                    self.shadowDocLabel.text = shadowDoc;
                });
                
                self.isSubscribe = true;
            }

        });
        
    }
    
    @IBAction func actPublishShadow(_ sender: Any) {
        if(isSubscribe){
            let shadowJson:String = getTestPublishDoc(testValue: "ok test!_01");
            print(shadowJson);
            
            IoTMqttService.sharedInstance().publishShadowDoc(shadowJson, topic: updateAccept, qoS: AWSIoTMQTTQoS.messageDeliveryAttemptedAtMostOnce);
            
        }
    }
    
    func getTestPublishDoc(testValue: String!) -> String {
        let shadowJson:NSMutableDictionary = NSMutableDictionary.init();
        let state:NSMutableDictionary = NSMutableDictionary.init();
        let desire:NSMutableDictionary = NSMutableDictionary.init();
        
        desire.setValue(testValue, forKey: "testValue");
        state.setValue(desire, forKey: "desired");
        shadowJson.setValue(state, forKey: "state")
        
        let jsonData: NSData;
        do{
            jsonData = try JSONSerialization.data(withJSONObject: shadowJson, options: JSONSerialization.WritingOptions()) as NSData;
            
            let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) as! String
            
            return jsonString;
        }catch _ {
            return "";
        }
        
    }
    
}

