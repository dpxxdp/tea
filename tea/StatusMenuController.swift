//
//  StatusMenuController.swift
//  tea
//
//  Created by Daniel Barrett on 4/17/16.
//  Copyright © 2016 Daniel Barrett. All rights reserved.
//

import Cocoa

let DEFAULT_ROUTE = "Red"
let DEFAULT_STOP = "70067"

class StatusMenuController: NSObject, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var currentPredictions = Array<Prediction>()
    var currentErrorMsg = ""
    var previousStateWasError = false;
    
    let mbtaClient = MbtaClient()
    var preferencesWindow: PreferencesWindow!
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.template = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        updatePredictions()
    }
    
    func updatePredictions() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let stopId = defaults.stringForKey("stop") ?? DEFAULT_STOP
        mbtaClient.fetchPredictionsByStop(stopId) { error, predictions in
            if(error != nil) {
                self.statusMenu.itemAtIndex(0)?.title = error!.domain
                self.statusMenu.itemAtIndex(1)?.title = "-"
                self.statusMenu.itemAtIndex(2)?.title = "-"
                self.statusMenu.itemAtIndex(3)?.title = "-"
            } else {
                self.statusMenu.itemAtIndex(0)?.title = "-"
                self.statusMenu.itemAtIndex(1)?.title = "-"
                self.statusMenu.itemAtIndex(2)?.title = "-"
                self.statusMenu.itemAtIndex(3)?.title = "-"
            }
        }
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func refreshClicked(sender: NSMenuItem) {
        updatePredictions();
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
    func preferencesDidUpdate() {
        updatePredictions()
    }
    
    
}
