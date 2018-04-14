//
//  Notify.swift
//  OpenTerm
//
//  Created by Jayant Varma on 14/4/18.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
import ios_system
import UserNotifications

fileprivate typealias FlagsDict = [String: String]
fileprivate let ValidFlags = ["title", "after", "badge"]
fileprivate var commandName: String = "Unknown"

public func notify(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> Int32 {

	guard let args = convertCArguments(argc: argc, argv: argv) else {
		return 1
	}
	
	commandName = args.first ?? "unknown"
	
	let usage = "Usage: \(commandName) message [-title TITLE] [-after SECONDS]\n"
	
	// Need atleast one argument passed which is the message
	if args.count < 2 {
		fputs(usage, thread_stderr)
		return 1
	}
	
	// Parse the flags
	let parsed = NotificationDataParser.parse(args: args)

	// ensure that no invalid flags are passed
	if let message = parsed.validateFlags() {
		fputs(message, thread_stdout)
		fputs(usage, thread_stdout)
		return 1
	}

	// Setup the variables before calling the Notification
	let message:String      = parsed.message
	let title:String        = parsed.flags["title"] ?? "Notification"
	let afterSeconds:Int    = Int(parsed.flags["after"] ?? "3") ?? 3
	let badge:String?       = parsed.flags["badge"]

	// Now create the Notification
	createNotification(message: message, title: title, afterSeconds: afterSeconds, badge: badge)
	
	return 0
}

fileprivate func createNotification(message: String, title: String, afterSeconds: Int, badge: String?) {
	let center = UNUserNotificationCenter.current()
	let options: UNAuthorizationOptions = [.alert, .sound, .badge]
	
	DispatchQueue.main.async {
		// Request for the Authorization only once and when you use the command, not for the app in general
		center.requestAuthorization(options: options) { (granted, error) in
			if !granted {
				fputs("Error  \(commandName): - permission not granted", thread_stdout)
				return
			}
		}

		let content = UNMutableNotificationContent()
		content.title = title
		content.body = message
		content.sound = UNNotificationSound.default()
	
		if let _badge = badge {
			if _badge == "reset" {
				content.badge = 0
			} else {
				if let _badgeNumber = Int(_badge) as NSNumber? {
					content.badge = _badgeNumber
				} else {
					content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
				}
			}
		} else {
			// Do Nothing
		}
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(afterSeconds), repeats: false)
		
		let identifier = "OpenTermNotification"
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		center.add(request) { (error) in
			if let error = error {
				fputs("Error occured - \(error)", thread_stdout)
			}
		}
	}
	
}

fileprivate struct NotificationData {
	var message      : String
	var flags		 : FlagsDict = [:]

	func validateFlags() -> String? {
		for (flag, flagValue) in flags {
			if !ValidFlags.contains(flag) {
				return " \(commandName): \(flag) is an invalid option"
			}
		}
		return nil
	}
}

fileprivate struct NotificationDataParser {
	// TODO: Use getOpts for better and consistent parsing

	static func parse(args: [String]) -> NotificationData {
		var message  : String?
		var currFlag : String?
		var flags	 : FlagsDict = [:]
		
		for arg in args.dropFirst() {
			if arg.hasPrefix("--") {
				currFlag = String(arg.dropFirst(2))
				continue
			}
			
			if let cFlag = currFlag {
				flags[cFlag] = arg
				currFlag = nil
				continue
			}
			
			if message == nil {
				message = arg
			}
		}
		
		return NotificationData(message: message ?? "", flags: flags )
	}
}
