//
//  AppDelegate.swift
//  20-20-20
//
//  Created by Tony Hu on 6/16/20.
//  Copyright © 2020 Tony Hu. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    //var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var notify = UserDefaults.standard.bool(forKey: "notifyStatus")

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
        
        NSApp.setActivationPolicy(.accessory)
        initializeStatusBar()
        startTimer()
    }
    
    func initializeStatusBar() {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem.button?.title = "👁"
        let statusBarMenu = NSMenu(title: "20-20-20 Menu")
        statusBarItem.menu = statusBarMenu
        
        statusBarMenu.addItem(
            withTitle: (notify ? "Notifications ON" : "Notifications OFF"),
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
    }
    
    func updateStatusBar() {
        let item = statusBarItem.menu?.item(at: 0)
        item?.title = (notify ? "Notifications ON" : "Notifications OFF")
        UserDefaults.standard.set(notify, forKey: "notifyStatus")
    }
    
    @objc func turnOnNotifications() {
        notify = true
        updateStatusBar()
    }
    
    @objc func turnOffNotifications() {
        notify = false
        updateStatusBar()
    }
    
    func startTimer() {
        // Wait for twenty minute intervals
        Timer.scheduledTimer(withTimeInterval: 1200, repeats: true) { timer in
            if (self.notify) {
                self.sendNotification()
            }
        }
    }
    
    func sendNotification() {
        let notification = NSUserNotification()
        notification.identifier = "notify20"
        notification.title = "20-20-20 Rule"
        notification.subtitle = "Look at something 20 feet away"
        notification.informativeText = "for 20 seconds."
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.hasActionButton = false
        
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.deliver(notification)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

