//
//  MbtaAPI.swift
//  tea
//
//  Created by Daniel Barrett on 4/17/16.
//  Copyright © 2016 Daniel Barrett. All rights reserved.
//

import Foundation

struct Trip {
    var id: String
    var headsign: String
    var pre_date: String
    var pre_away: String
}

struct Stop {
    var id: String
    var name: String
    var modeId: String
    var modeName: String
    var routeId: String
    var routeName: String
    var trips: NSArray
}

class MbtaClient {
    
    let API_KEY = "ZaL-rNuhvkGlzp9fA6SwSg"
    let FORMAT = "json"
    let BASE_URL = "http://realtime.mbta.com/developer/api/v2/"
    
    let API_QUERY = "?api_key="
    let FORMAT_QUERY = "&format="
    let STOP_QUERY = "&stop="
    let ROUTE_QUERY = "&route="
    
    let PREDICTIONS_BY_STOP_TOPIC = "predictionsByStop"
    let STOPS_BY_ROUTE_TOPIC = "stopsByRoute"
    let ROUTES_TOPIC = "routes"
    
    let HA_STOP_ID = "70067"

    
    func getUrl(topic: String, query: String) -> String {
        return BASE_URL + topic + API_QUERY + API_KEY + query + FORMAT_QUERY + FORMAT
    }
    
    func getPredictionByStopQuery(stopId: String) -> String {
        let query = STOP_QUERY + stopId
        return getUrl(PREDICTIONS_BY_STOP_TOPIC, query: query)
    }
    
    func getStopsByRouteQuery(routeId: String) -> String {
        let query = ROUTE_QUERY + routeId
        return getUrl(STOPS_BY_ROUTE_TOPIC, query: query)
    }
    
    func getRoutesQuery() -> String {
        let query = ""
        return getUrl(ROUTES_TOPIC, query: query)
    }
    
    func fetchPredictionsByStop(stopId: String) -> String {
        let returnData = fetchData(getPredictionByStopQuery(stopId))
        let stop = stopFromJSON(returnData)
        return stop.trips
    }
    
    func stopFromJSON(data: NSData) -> Stop? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        var mainDict = json["main"] as! JSONDict
        var stopList = json["stop"] as! [JSONDict]
        var stopDict = stopList[0]
        
        let stop = Stop(
            name: json["stop_name"] as! String,
            id: mainDict["stop_id"] as! String,
        )
        
        return stop
    }
    
    func fetchPredictionsByStop(stopId: String, callback:(NSError?, Stop?) -> Void) -> String {
        
        
        self.fetchData(getPredictionByStopQuery(stopId)) { error, data in
            if(error != nil) {
                callback(error, nil)
            } else {
                let stop = self.stopFromJSON(data!)
            }
        }
        
        
        return stop.trips
    }
    
    func fetchData(urlString: String, callback: (NSError?, NSData?) -> Void) {
        let session = NSURLSession.sharedSession()
        // url-escape the query string we're passed

        let url = NSURL(string: urlString)
        let task = session.dataTaskWithURL(url!) { data, response, error in
            // first check for a hard error
            if error != nil{
                callback(error, nil)
            }
            
            // then check the response code
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200: // all good!
                    callback(nil, data!)
                case 401: // unauthorized
                    NSLog("weather api returned an 'unauthorized' response. Did you set your API key?")
                    let authErr = NSError(domain: "fetchData returned 401", code: 1, userInfo: nil)
                    callback(authErr, nil)
                default:
                    NSLog("weather api returned response: %d %@", httpResponse.statusCode, NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode))
                    let authErr = NSError(domain: "fetchData returned non 200", code: 1, userInfo: nil)
                    callback(authErr, nil)
                }
            }
        }
        task.resume()
    }
}
    
}