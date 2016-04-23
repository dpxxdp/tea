//
//  PreferencesWindow.swift
//  tea
//
//  Created by Dan Barrett on 4/21/16.
//  Copyright © 2016 Daniel Barrett. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    @IBOutlet weak var route: NSPopUpButton!
    @IBOutlet weak var stop: NSPopUpButton!
    @IBOutlet weak var frequency: NSPopUpButton!
    
    var delegate: PreferencesWindowDelegate?
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let r = defaults.stringForKey("route") ?? DEFAULT_ROUTE
        route.stringValue = r
    }
    
    func windowWillClose(notification: NSNotification) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(route.stringValue, forKey: "route")
        defaults.setValue(stop.stringValue, forKey: "stop")
        defaults.setValue(frequency.stringValue, forKey: "frequency")
        
        delegate?.preferencesDidUpdate()
    }
}