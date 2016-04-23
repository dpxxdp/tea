//
//  Preferences.swift
//  tea
//
//  Created by Daniel Barrett on 4/19/16.
//  Copyright © 2016 Daniel Barrett. All rights reserved.
//

import Foundation

public struct TimeTuple {
    let start: NSDate;
    let end: NSDate;
}

public class PreferenceSet {
    var routes = ["Red", "Blue", "Orange", "Green"]
    var currentRouteId = "Red"
    var currentStopId = "70067"
    
    var timerInterval = 20000
    var timerWeekdays = [2,3,4,5,6,7]
    var timerHours = Array<TimeTuple>();
    
    
    
}