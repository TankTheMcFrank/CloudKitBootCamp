//
//  CloudKitPushNotificationBootcamp.swift
//  CloudKitBootCamp
//
//  Created by Frank Herring on 10/6/23.
//

import CloudKit
import SwiftUI

class CloudKitPushNotificationBootcampViewModel: ObservableObject {
    
    func requestNotificationPermissions() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print(error)
            } else if success {
                print("Notification permissions success!")
                
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("Notification permissions failure.")
            }
        }
    }
    
    func subscribeToNotifications() {
        let predicate = NSPredicate(value: true) /* gets all records where the type is Fruits */
        let subscription = CKQuerySubscription(recordType: "Fruits", predicate: predicate, subscriptionID: "fruit_added_to_database", options: .firesOnRecordCreation)
        
        let notification = CKSubscription.NotificationInfo()
        notification.title = "There's a new fruit!"
        notification.alertBody = "Open the app to check your fruits."
        notification.soundName = "default"
        
        subscription.notificationInfo = notification
        
        CKContainer.default().publicCloudDatabase.save(subscription) { returnedSubscription, returnedError in
            if let error = returnedError {
                print(error)
            } else {
                print("Successly subscribed to notifications!")
            }
        }
    }
    
    func unsubscribeToNotifications() {
        /* use the following three lines of code to get fetch all subscriptions, if
            you're unsure of which one you need to select at first */
//        CKContainer.default().publicCloudDatabase.fetchAllSubscriptions { returnedSubscriptions, returnedError in
//            //Code
//        }
        
        CKContainer.default().publicCloudDatabase.delete(withSubscriptionID: "fruit_added_to_database") { returnedID, returnedError in
            if let error = returnedError {
                print(error)
            } else {
                print("Sucessfully unsubscribed!")
            }
        }
    }
    
}

struct CloudKitPushNotificationBootcamp: View {
    
    @StateObject private var vm = CloudKitPushNotificationBootcampViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Button("Request notification permissions") {
                vm.requestNotificationPermissions()
            }
            
            Button("Subscribe to notifications") {
                vm.subscribeToNotifications()
            }
            
            Button("Unsubscribe to notifications") {
                vm.subscribeToNotifications()
            }
        }
    }
}

//#Preview {
//    CloudKitPushNotificationBootcamp()
//}
