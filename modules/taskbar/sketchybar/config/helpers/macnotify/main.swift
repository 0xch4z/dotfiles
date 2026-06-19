#!/usr/bin/swift

import Foundation
import UserNotifications

guard CommandLine.arguments.count >= 3 else {
    print("Usage: \(CommandLine.arguments[0]) <title> <body>")
    exit(1)
}

let title = CommandLine.arguments[1]
let body = CommandLine.arguments[2]

let content = UNMutableNotificationContent()
content.title = title
content.body = body
content.sound = UNNotificationSound.default

let request = UNNotificationRequest(
    identifier: UUID().uuidString,
    content: content,
    trigger: nil // Send immediately
)

let center = UNUserNotificationCenter.current()

center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    guard granted else {
        print("Notification permission denied")
        exit(1)
    }
    
    center.add(request) { error in
        if let error = error {
            print("Error sending notification: \(error)")
            exit(1)
        }
        exit(0)
    }
}

RunLoop.main.run()
