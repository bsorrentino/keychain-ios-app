//
//  SendLocalNotificationCell.swift
//  KeyChain
//
//  Created by softphone on 13/06/2018.
//  Copyright © 2018 SOFTPHONE. All rights reserved.
//

import UIKit
import UserNotifications

@objc class SendLocalNotificationCell: BaseDataEntryCell {

    @IBOutlet weak var buttonNotification: UIButton!
    weak var controller:KeyEntityFormController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func authorizeNotification( _ value:Bool ) {
        DispatchQueue.main.async {
            self.buttonNotification.isEnabled = value
        }
        if( value ) {
            UNUserNotificationCenter.current().delegate = self
        }

    }
    
    private func suspedApp() {

        DispatchQueue.main.async {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        }
    }
    override func prepare(toAppear controller: UIXMLFormViewController, datakey key: String, cellData: [AnyHashable : Any]?)
    {
        if let c = controller as? KeyEntityFormController  {
            
            
            let center = UNUserNotificationCenter.current()
            
            center.getNotificationSettings { (settings) in
                
                switch settings.authorizationStatus {
                case .authorized:
                    self.authorizeNotification(true)
                case .denied:
                    self.authorizeNotification(false)
                case .notDetermined:
                    let options: UNAuthorizationOptions = [.alert, .sound];
                    
                    center.requestAuthorization(options: options) {
                        (granted, error) in
                        guard error == nil else  {
                            return
                        }
                        
                        self.authorizeNotification(granted)
                    }
                
                case .provisional:
                    print( "provisional" )
                }
            }

            self.controller = c

        }
    }

    @IBAction func onAction() {        

        if let c = self.controller, let passwd = c.entity.password {

            let center = UNUserNotificationCenter.current()

            let content = UNMutableNotificationContent()
            content.title = "take a look"
            content.body = passwd
            content.sound = UNNotificationSound.default()

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                            repeats: false)
            
            let identifier = "KeyChainLocalNotification"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content,
                                                trigger: trigger)
            center.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print( "error adding notification \(error)")
                }
                else {
                    //self.suspedApp()
                }
            })
            
        }
    }
    
}

extension SendLocalNotificationCell : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if response.notification.request.identifier == "localNotification" {
            
            completionHandler()
        }
        
    }
}

