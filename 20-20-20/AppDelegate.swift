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
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    //var window: NSWindow!
    var statusBarItem: NSStatusItem!
    var timer: Timer!
    var notifyStatus = UserDefaults.standard.integer(forKey: "notifyStatus")  // uninitialized = 0, ON = 1, OFF = -1
    var soundStatus = UserDefaults.standard.integer(forKey: "soundStatus")  // uninitialized = 0, ON = 1, OFF = -1
    let twentySecs = 20.0
    let twentyMins = 1200.0
    let appVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

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
        
        // Handle notifications depending on sleep status
        let notificationCenter = NSWorkspace.shared.notificationCenter
        notificationCenter.addObserver(self, selector: #selector(stopTimer), name: NSWorkspace.willSleepNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(checkNotifyStatus), name: NSWorkspace.didWakeNotification, object: nil)
        
        NSApp.setActivationPolicy(.accessory)
        
        // Ask first time user for notification permissions
        if (notifyStatus == 0) {
            sendNotification()
            notifyStatus = 1
        }
        
        if (soundStatus == 0) {
            soundStatus = 1
        }
        
        initializeStatusBar()
        checkNotifyStatus()
    }
    
    @objc func checkNotifyStatus() {
        if (notifyStatus == 1) {
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
            withTitle: ((notifyStatus == 1) ? "Notifications ON" : "Notifications OFF"),
            action: nil,
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: ((notifyStatus == 1) ? "Turn OFF Notifications" : "Turn ON Notifications"),
            action: #selector(AppDelegate.updateNotifications),
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: ((soundStatus == 1) ? "Disable Sounds" : "Enable Sounds"),
            action: #selector(AppDelegate.updateSounds),
            keyEquivalent: "")
        
        statusBarMenu.addItem(NSMenuItem.separator())
        
        statusBarMenu.addItem(
            withTitle: "Version: " + appVersion,
            action: nil,
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: "Check for Updates",
            action: #selector(AppDelegate.openReleases),
            keyEquivalent: "")
        
        statusBarMenu.addItem(
            withTitle: "Give Feedback",
            action: #selector(AppDelegate.openFeedback),
            keyEquivalent: "")
        
        statusBarMenu.addItem(NSMenuItem.separator())
        
        statusBarMenu.addItem(
            withTitle: "Quit",
            action: #selector(AppDelegate.exitApp),
            keyEquivalent: "")
    }
    
    @objc func updateNotifications() {
        if (notifyStatus == 1) {
            stopTimer()
            notifyStatus = -1
            updateStatusBar()
            UserDefaults.standard.set(notifyStatus, forKey: "notifyStatus")
        }
        else {
            startTimer()
            notifyStatus = 1
            updateStatusBar()
            UserDefaults.standard.set(notifyStatus, forKey: "notifyStatus")
        }
    }
    
    func updateStatusBar() {
        let statusItem = statusBarItem.menu?.item(at: 0)
        statusItem?.title = ((notifyStatus == 1) ? "Notifications ON" : "Notifications OFF")
        let notifyOptionItem = statusBarItem.menu?.item(at: 1)
        notifyOptionItem?.title = ((notifyStatus == 1) ? "Turn OFF Notifications" : "Turn ON Notifications")
        let soundOptionItem = statusBarItem.menu?.item(at: 2)
        soundOptionItem?.title = ((soundStatus == 1) ? "Disable Sounds" : "Enable Sounds")
    }
    
    @objc func updateSounds() {
        soundStatus = (soundStatus == 1) ? -1 : 1
        updateStatusBar()
        UserDefaults.standard.set(soundStatus, forKey: "soundStatus")
    }
    
    @objc func openReleases() {
        let url = URL(string: "https://github.com/tonyh4156/20-20-20/releases")!
        if (NSWorkspace.shared.open(url)) {
            print("Successfully opened github releases!")
        }
    }
    
    @objc func openFeedback() {
        let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSfXnoCmppLdI-kttHYPE6bO4JoXW7nF6ZG2xTw6wPwddlHFCA/viewform")!
        if (NSWorkspace.shared.open(url)) {
            print("Successfully opened feedback form!")
        }
    }
    
    @objc func exitApp() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func startTimer() {
        // Wait for twenty minute intervals
        timer = Timer.scheduledTimer(withTimeInterval: twentyMins, repeats: true) { t in
            if (self.notifyStatus == 1) {
                self.sendNotification()
            }
        }
    }
    
    @objc func stopTimer() {
        if (timer != nil) {
            timer.invalidate()
        }
    }
    
    func sendNotification() {
        let notification = NSUserNotification()
        notification.identifier = "notify20"
        notification.title = "20-20-20 (Expires in 20 secs)"
        notification.subtitle = "Look at something 20 feet away"
        notification.informativeText = "for 20 seconds."
        notification.soundName = (soundStatus == 1) ? NSUserNotificationDefaultSoundName : nil
        notification.hasActionButton = false
        
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.deliver(notification)
        
        // Display notification for twenty seconds
        notificationCenter.perform(#selector(NSUserNotificationCenter.removeDeliveredNotification(_:)),
                                   with: notification,
                                   afterDelay: (twentySecs))
                                        
        if (soundStatus == 1) {
            perform(#selector(playSound), with: nil, afterDelay: twentySecs)
        }
    }
    
    @objc func playSound() {
        NSSound(named: "pieceOfCake")?.play()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
