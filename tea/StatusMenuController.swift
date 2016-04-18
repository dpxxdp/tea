//
//  StatusMenuController.swift
//  tea
//
//  Created by Daniel Barrett on 4/17/16.
//  Copyright © 2016 Daniel Barrett. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    let mbtaClient = MbtaClient()
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.template = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        mbtaClient.fetchData()
    }
    
    @IBAction func refreshClicked(sender: NSMenuItem) {
        mbtaClient.fetchData()
    }
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}
