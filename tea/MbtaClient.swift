//
//  MbtaAPI.swift
//  tea
//
//  Created by Daniel Barrett on 4/17/16.
//  Copyright © 2016 Daniel Barrett. All rights reserved.
//

import Foundation

public struct Stop {
    var id: String
    var name: String
    var modeName: String
    var routeName: String
}

public struct Prediction {
    var stop_id: String
    var id: String
    var headsign: String
    var pre_date: NSDate
    var pre_away: NSTimeInterval
    var timestamp: NSDate
}

public class MbtaClient {
    
    public func fetchPredictionsByStop(stopId: String, callback:(NSError?, Array<Prediction>?) -> Void) {
        self.fetchData(generatePredictionsByStopUrl(stopId)) { error, data in
            if(error != nil) {
                callback(error, nil)
            } else {
                let predictions = self.deserializePredictions(data!)
                callback(nil, predictions)
            }
        }
    }
    
    public func fetchStopsByRoute(routeId: String, callback:(NSError?, Array<Stop>?) -> Void) {
        self.fetchData(generateStopsByRouteUrl(routeId)) { error, data in
            if(error != nil) {
                callback(error, nil)
            } else {
                let stops = self.deserializeStops(data!)
                callback(nil, stops)
            }
        }
    }
    
    //helpers and private variables
    
    private let API_KEY = "ZaL-rNuhvkGlzp9fA6SwSg"
    private let FORMAT = "json"
    private let BASE_URL = "http://realtime.mbta.com/developer/api/v2/"
    
    private let API_QUERY = "?api_key="
    private let FORMAT_QUERY = "&format="
    
    private func getUrl(topic: String, query: String) -> String {
        return BASE_URL + topic + API_QUERY + API_KEY + query + FORMAT_QUERY + FORMAT
    }
    
    //stop helpers
    
    private let STOPS_BY_ROUTE_TOPIC = "stopsByRoute"
    private let ROUTE_QUERY = "&route="
    
    private func generateStopsByRouteUrl(routeId: String) -> String {
        let query = ROUTE_QUERY + routeId
        return getUrl(STOPS_BY_ROUTE_TOPIC, query: query)
    }
    
    private func deserializeStops(data: NSData) -> Array<Stop>? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        var mainDict = json["main"] as! JSONDict
        
        var stops = Array<Stop>();
        //foreach
        let stop = Stop(
            id: mainDict["stop_id"] as! String,
            name: json["stop_name"] as! String,
            modeName: json["mode_name"] as! String,
            routeName: json["route_name"] as! String
        )
        stops.append(stop)
        //
        
        return stops
    }
    
    //prediction helpers
    
    private let PREDICTIONS_BY_STOP_TOPIC = "predictionsByStop"
    let STOP_QUERY = "&stop="

    private func generatePredictionsByStopUrl(stopId: String) -> String {
        let query = STOP_QUERY + stopId
        return getUrl(PREDICTIONS_BY_STOP_TOPIC, query: query)
    }
    
    private func deserializePredictions(data: NSData) -> Array<Prediction>? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        var predictions = Array<Prediction>();
        
        //foreach
        let prediction = Prediction(
            stop_id: "TODO:TEST_STOP_ID",
            id: "TODO:TEST_ID",
            headsign: "TODO:ASHMONT",
            pre_date: NSDate(timeIntervalSince1970: NSTimeInterval(1234123)),
            pre_away: NSTimeInterval(3462456345),
            timestamp: NSDate()
        )
        predictions.append(prediction);
        //
        
        return predictions
    }
    
    //api call
    
    private func fetchData(urlString: String, callback: (NSError?, NSData?) -> Void) {
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