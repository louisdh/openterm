//
//  AppDelegate.swift
//  OpenTerm
//
//  Created by Louis D'hauwe on 07/12/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import UIKit
import TabView
import CoreSpotlight
import MobileCoreServices
import ios_system

#if canImport(SimulatorStatusMagic)
	import SimulatorStatusMagic
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

		window = UIWindow(frame: UIScreen.main.bounds)
		window?.rootViewController = TabViewContainerViewController<TerminalTabViewController>(theme: TabViewThemeDark())
		window?.tintColor = .defaultMainTintColor
		window?.makeKeyAndVisible()

		do {
			try FileManager.default.downloadAllFromCloud(at: DocumentManager.shared.scriptsURL)
		} catch {
			print(error)
		}
		
		#if canImport(SimulatorStatusMagic)
			SDStatusBarManager.sharedInstance().enableOverrides()
		#endif
		
		indexCommands()
		
		return true
	}
	
	func indexCommands() {
		
		CSSearchableIndex.default().deleteAllSearchableItems { (error) in
			
			let systemCommands = (commandsAsArray() as? [String] ?? []).sorted()
			let commands = systemCommands + CommandManager.shared.scriptCommands
			
			for command in commands {
				
				let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
				attributeSet.title = command
				attributeSet.contentDescription = CommandManager.shared.description(for: command)
				
				let item = CSSearchableItem(uniqueIdentifier: "\(command)", domainIdentifier: "com.silverfox.Terminal", attributeSet: attributeSet)
				CSSearchableIndex.default().indexSearchableItems([item]) { error in
					if let error = error {
						print("Indexing error: \(error.localizedDescription)")
					} else {
						print("Search item successfully indexed!")
					}
				}
				
			}
			
		}
		
	}

	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
		
		if userActivity.activityType == CSSearchableItemActionType {
			
			guard let command = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
				return false
			}
		
			guard let navigationController = window?.rootViewController as? TabViewContainerViewController<TerminalTabViewController> else {
				return false
			}
			
			guard let viewController = navigationController.primaryTabViewController.visibleViewController as? TerminalViewController else {
				return false
			}
				
			viewController.terminalView.currentCommand = command
			
			if viewController.presentedViewController == nil {
				viewController.terminalView.becomeFirstResponder()
			}
			
		}
		
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
		// feed x-callback-url data into xCallbackUrl logic, where it is safe to pass in other URL's
		// as xCallbackUrlOpen returns false for stuff it does not understand.
		if xCallbackUrlOpen(url) {
			return true
		}

		// we could not do anything with this URL
		return false
	}
}
