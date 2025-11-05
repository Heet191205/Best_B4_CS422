//
//  AppDelegate.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 7/30/25.
//

import UIKit
import CoreData
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
        lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "foodExpirationTracker")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do{
                try context.save()
                
            }catch{
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            completionHandler([.banner, .sound, .badge])
            print("Notification received in foreground: \(notification.request.content.title) - \(notification.request.content.body)")
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
         let notificationIdentifier = response.notification.request.identifier
         let notificationTitle = response.notification.request.content.title
         let notificationBody = response.notification.request.content.body
         print("Notification tapped - Identifier: \(notificationIdentifier), Title: \(notificationTitle), Body: \(notificationBody)")
       
         if notificationIdentifier.hasPrefix("food_expiration_") {
             print("Food expiration notification tapped. User might want to see their food list.")
             // In a real app, you might navigate to the HomeScreen or even to the detail view of the specific food item.
             // (Navigation logic for this would involve accessing the window's root view controller, e.g., TabBarController)
         }
         
         completionHandler() // Always call the completion handler to tell the system you're done processing the response.
     }
}

