//
//  AppDelegate.swift
//  Todoey
//
//  Created by Shivani Aggarwal on 2018-04-29.
//  Copyright © 2018 Shivani Aggarwal. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm()

        } catch {
            print("Error initializing new realm \(error)")
        }
        
        return true
    }

 
}






