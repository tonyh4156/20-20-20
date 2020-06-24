//
//  AppDelegate.swift
//  20-20-20
//
//  Created by Tony Hu on 6/16/20.
//  Copyright © 2020 Tony Hu. All rights reserved.
//

import Cocoa
import SwiftUI
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var timer: Timer!
    var notify = UserDefaults.standard.integer(forKey: "notifyStatus")  // uninitialized = 0, ON = 1, OFF = -1
    let twentySecs = 20.0
    let twentyMins = 60.0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        /*let contentView = ContentView()

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)*/
        
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(self, selector: #selector(stopTimer), name: NSWorkspace.willSleepNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(checkStatus), name: NSWorkspace.didWakeNotification, object: nil)
        
        NSApp.setActivationPolicy(.accessory)
        initializeStatusBar()
        
        // Ask first time user for notification permissions
        if (notify == 0) {
            sendNotification()
            notify = 1
        }
        
        checkStatus()
    }
    
    @objc func checkStatus() {
        if (notify == 1) {
            startTimer()
        }
    }
    
    func initializeStatusBar() {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.title = "👁"
        let statusBarMenu = NSMenu(title: "20-20-20 Menu")
        statusBarItem.menu = statusBarMenu
        
        statusBarMenu.addItem(
            withTitle: ((notify == 1) ? "Notifications ON" : "Notifications OFF"),
            action: nil,
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: "Turn ON Notifications",
            action: #selector(AppDelegate.turnOnNotifications),
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: "Turn OFF Notifications",
            action: #selector(AppDelegate.turnOffNotifications),
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.exitApp),
            keyEquivalent: "")
    }
    
    func updateStatusBar() {
        let item = statusBarItem.menu?.item(at: 0)
        item?.title = ((notify == 1) ? "Notifications ON" : "Notifications OFF")
        UserDefaults.standard.set(notify, forKey: "notifyStatus")
    }
    
    @objc func turnOnNotifications() {
        notify = 1
        updateStatusBar()
        startTimer()
    }
    
    @objc func turnOffNotifications() {
        notify = -1
        updateStatusBar()
        stopTimer()
    }
    
    @objc func exitApp() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func startTimer() {
        // Wait for twenty minute intervals
        timer = Timer.scheduledTimer(withTimeInterval: twentyMins, repeats: true) { t in
            if (self.notify == 1) {
                self.sendNotification()
            }
        }
    }
    
    @objc func stopTimer() {
        timer.invalidate()
    }
    
    func sendNotification() {
        let notification = NSUserNotification()
        notification.identifier = "notify20"
        notification.title = "20-20-20 (Expires in 20 secs)"
        notification.subtitle = "Look at something 20 feet away"
        notification.informativeText = "for 20 seconds."
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = false
        
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.deliver(notification)
        
        // Display notification for twenty seconds
        notificationCenter.perform(#selector(NSUserNotificationCenter.removeDeliveredNotification(_:)),
                                   with: notification,
                                   afterDelay: (twentySecs))
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
