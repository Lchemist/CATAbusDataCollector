//
//  GetData.swift
//  BusMonitor
//
//  Created by Ray Xuan on 3/8/17.
//  Copyright © 2017 RayX. All rights reserved.
//

import Foundation
struct cell2Data {
    var cell : Int!
    var priority : Int! // For better view order - 0: Low 1: Mid 2: High
    var route : String?
    var direction : String?
    var info : [String]!
}
class GetData {
    var content : String
    var id : String
    var bus : String
    var description : String
    var lat : String
    var lng : String
    
    init?() {
        self.content = ""
        self.id = ""
        self.bus = ""
        self.description = " "
        self.lat = ""
        self.lng = ""
    }
    
    func ofRoutes(urlString: String) -> [[String]]{
        do {
            // Get timetable from url
            let url = URL(string: urlString)!
            var content = try String(contentsOf: url, encoding: .utf8)
            
            
            // Reduce the string to the needed range then strip away white spaces
            if let rangeOfStart = content.range(of: "content\">") {
                content = content.substring(from: rangeOfStart.upperBound)
            }
            if let rangeOfEnd = content.range(of: "</div>") {
                content = content.substring(to: rangeOfEnd.lowerBound).trimmingCharacters(in: NSCharacterSet.whitespaces)
            }
            
            // Convert into array
            let bufArray = content.components(separatedBy: CharacterSet.newlines)
            var finalArray = [[String]]()
            var row = [String]()
            for var buf in bufArray {
                if buf != "" {
                    if let rangeOfStart = buf.range(of: "routeID=\"") {
                        buf = buf.substring(from: rangeOfStart.upperBound)
                    }
                    if let rangeOfEnd = buf.range(of: "\">") {
                        id = buf.substring(to: rangeOfEnd.lowerBound)
                    }
                    if let rangeOfStart = buf.range(of: "\">") {
                        buf = buf.substring(from: rangeOfStart.upperBound)
                    }
                    if let rangeOfEnd = buf.range(of: " - ") {
                        bus = buf.substring(to: rangeOfEnd.lowerBound)
                        buf = buf.substring(from: rangeOfEnd.upperBound)
                        if let rangeOfEnd = buf.range(of: "</a>") {
                            description = buf.substring(to: rangeOfEnd.lowerBound)
                        }
                    }
                    else {
                        if let rangeOfEnd = buf.range(of: "</a>") {
                            bus = buf.substring(to: rangeOfEnd.lowerBound)
                        }
                    }
                    row = []
                    row.append(id)
                    row.append(bus)
                    row.append(description)
                    finalArray.append(row)
                }
            }
            
            return finalArray
        } catch  {
            //print("Error: \(error)")
            var emptyList = [[String]]()
            emptyList.append(["Please Check Your Network Setting"])
            emptyList.append(["Pull Down to Refresh"])
            return emptyList
        }
    }
    
    func ofStops(urlString: String) -> [[String]]{
        do {
            // Get timetable from url
            let url = URL(string: urlString)!
            var content = try String(contentsOf: url, encoding: .utf8)
            // Reduce the string to the needed range then strip away white spaces
            if let rangeOfStart = content.range(of: "<table border=\"0\">") {
                content = content.substring(from: rangeOfStart.upperBound)
            }
            if let rangeOfEnd = content.range(of: "</table>") {
                content = content.substring(to: rangeOfEnd.lowerBound).trimmingCharacters(in: NSCharacterSet.whitespaces)
            }
            
            // Convert into array
            let bufArray = content.components(separatedBy: CharacterSet.newlines)
            var finalArray = [[String]]()
            var row = [String]()
            var even = 0
            for var buf in bufArray {
                buf = buf.trimmingCharacters(in: NSCharacterSet.whitespaces)
                if (buf != "" && buf != "<tr>" && buf != "</tr>") {
                    even += 1
                    if (even == 2) {
                        if let rangeOfStart = buf.range(of: "stopid=\"") {
                            buf = buf.substring(from: rangeOfStart.upperBound)
                        }
                        if let rangeOfEnd = buf.range(of: "\">") {
                            id = buf.substring(to: rangeOfEnd.lowerBound)
                        }
                        if let rangeOfStart = buf.range(of: "\">") {
                            buf = buf.substring(from: rangeOfStart.upperBound)
                        }
                        if let rangeOfEnd = buf.range(of: "</a>") {
                            description = buf.substring(to: rangeOfEnd.lowerBound)
                        }
                        row = []
                        row.append(id)
                        row.append(description)
                        
                        finalArray.append(row)
                        even = 0
                    }
                }
            }
            return finalArray
        } catch  {
            //print("Error: \(error)")
            let emptyList = [[String]]()
            return emptyList
        }
    }
    
    func ofTimes(urlString: String) -> [cell2Data]{
        do {
            // Get timetable from url
            let url = URL(string: urlString)!
            var content = try String(contentsOf: url, encoding: .utf8)
            
            // Reduce the string to the needed range then strip away white spaces
            if let rangeOfStart = content.range(of: "</h1>") {
                content = content.substring(from: rangeOfStart.upperBound)
            }
            if let rangeOfEnd = content.range(of: "<h3 style=") {
                content = content.substring(to: rangeOfEnd.lowerBound).trimmingCharacters(in: NSCharacterSet.whitespaces)
            }
            
            // Filter out the html tags & tab space
            content = content.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
            content = content.replacingOccurrences(of: "\t", with: "", options: String.CompareOptions.literal, range:nil)
            
            // Convert into array
            let rawArray = content.components(separatedBy: CharacterSet.newlines)
            
            // Initialize time datas
            let dateFormatter = DateFormatter()
            let dateCompoFormatter = DateComponentsFormatter()
            dateCompoFormatter.unitsStyle = .abbreviated
            dateCompoFormatter.allowedUnits = [.hour,.minute]
            dateCompoFormatter.maximumUnitCount = 2
            let now = Date()
            
            // Initialize datas
            var finalArray = [cell2Data]()
            var midArray = [String]()
            var bufString = String()
            var info = ""
            var direction = ""
            var newline = ""
            for buf in rawArray {
                if buf != "" {
                    var bufArray = buf.trimmingCharacters(in: NSCharacterSet.whitespaces).components(separatedBy: " ")
                    direction = " "
                    if bufArray.contains("Done") || bufArray.contains("Due"){ // if no bus is avaliable
                        bufArray[0] = " No-Bus-Avaliable"
                        direction = ""
                        newline = ""
                    }
                    else if bufArray[0].contains(":") { // if it's time
                        dateFormatter.dateFormat = "h:mma"
                        // Calculate time difference & convert xx:xx PM to xx:xxPM
                        let then = dateFormatter.date(from: bufArray[0]+bufArray[1])
                        bufArray[0] = " " + dateCompoFormatter.string(from: dateFormatter.date(from:dateFormatter.string(from: now))!
                            , to: then!)!.replacingOccurrences(of: " ", with: "", options: String.CompareOptions.literal, range:nil)
                        
                        // Remove special case such as "-22h54m" (to "12:45AM")
                        if bufArray[0][bufArray[0].index(bufArray[0].startIndex, offsetBy: 1)] == "-" {
                            let bufTime = bufArray[0].replacingOccurrences(of: "-", with: "", options: String.CompareOptions.literal, range:nil).replacingOccurrences(of: "m", with: "", options: String.CompareOptions.literal, range:nil).replacingOccurrences(of: " ", with: "", options: String.CompareOptions.literal, range:nil).components(separatedBy: "h")
                            
                            let bufMin = 24*60-Int(bufTime[0])!*60-Int(bufTime[1])!
                            if bufMin >= 60 {
                                if bufMin%60 == 0 {
                                    bufArray[0] = " " + String(bufMin/60)+"h"
                                } else {
                                    bufArray[0] = " " + String(bufMin/60)+"h"+String(bufMin%60)+"m"
                                }
                            } else {
                                bufArray[0] = " " + String(bufMin) + "m"
                            }
                        }
                        direction = ""
                        newline = ""
                    }
                    else if bufArray[0].contains("Every") {
                        bufArray[0] = " " + bufArray[0] + "-" + bufArray[1] + "-" + bufArray[2]
                        direction = ""
                        newline = ""
                    }
                    else if bufArray.contains("Red") && bufArray.contains("Inbound") {
                        bufArray[0] = "RL"
                        direction = " inbound "
                    }
                    else if bufArray.contains("Red") && bufArray.contains("Outbound") {
                        bufArray[0] = "RL"
                        direction = " outbound "
                    }
                    else if bufArray.contains("Inbound") {
                        direction = " inbound "
                    }
                    else if bufArray.contains("Outbound") {
                        direction = " outbound "
                    }
                    else if bufArray.contains("Blue") {
                        bufArray[0] = "BL"
                    }
                    else if bufArray.contains("White") {
                        bufArray[0] = "WL"
                    }
                    else if bufArray.contains("Green") {
                        bufArray[0] = "GL"
                    }
                    else if bufArray.contains("Downtown") {
                        bufArray[0] = "D.F.shuttle"
                    }
                    else if bufArray.contains("South") {
                        bufArray[0] = "S.A.F.shuttle"
                    }
                    
                    info = newline+bufArray[0]+direction
                    
                    midArray.append(info)
                    newline = "\n"
                }
            }
            bufString = midArray.joined(separator: "")
            midArray = bufString.components(separatedBy: "\n")
            var priority: Int! = 1
            var route : String?
            var direc : String?
            var infoArray = [String]()
            
            for (i,data) in midArray.enumerated() {
                // Line of info - exp: VE inbound 11:50AM 02:30PM
                let bufArray = data.components(separatedBy: " ")
                for (index,text) in bufArray.enumerated() {
                    if index == 0 { // Route Name - first element in each line
                        route = text
                    } else if text == "inbound" || text == "outbound" { // Direction - 2nd
                        direc = text
                    } else { // Time Info
                        if text != "" { // Filter out ""
                            if text == "No-Bus-Avaliable" {
                                priority = 0 // Lowest priority
                            }
                            
                            infoArray.append(text.replacingOccurrences(of: "-", with: " ", options: String.CompareOptions.literal, range:nil))
                        }
                    }
                }
                finalArray.append(cell2Data(cell: i+1, priority: priority, route: route, direction: direc, info: infoArray))
                // Reset variables value to default to prevent bug in next line
                priority = 1 // Normal priority
                route = nil
                direc = nil
                infoArray.removeAll(keepingCapacity: false)
                //finalArray.append(bufArray)
            }
            // Return sorted (by priority) schedule list
            return finalArray.sorted {$0.priority > $1.priority}
        } catch {
            //print("Error: \(error)")
            var emptyList = [cell2Data]()
            emptyList.append(cell2Data(cell: 1, priority: 0, route: "N/A", direction: "offline", info: ["Network Connection Lost"]))
            
            return emptyList
        }
    }
    
    // Extract Coordinates of The Request Location With Google MapGeocodeAPI
    func ofCoord(urlString: String) -> String{
        do {
            // Get timetable from url
            let url = URL(string: urlString)!
            var content = try String(contentsOf: url, encoding: .utf8)
            
            // Filter out the html tags & tab space
            content = content.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
            content = content.replacingOccurrences(of: "\t", with: "", options: String.CompareOptions.literal, range:nil)
            // Reduce the string to the needed range then strip away white spaces
            if let rangeOfStart = content.range(of: "\"lat\" : ") {
                content = content.substring(from: rangeOfStart.upperBound)
            }
            if let rangeOfEnd = content.range(of: ",") {
                lat = content.substring(to: rangeOfEnd.upperBound)
            }
            if let rangeOfStart = content.range(of: "\"lng\" : ") {
                content = content.substring(from: rangeOfStart.upperBound)
            }
            if let rangeOfEnd = content.range(of: "\n") {
                lng = content.substring(to: rangeOfEnd.lowerBound).trimmingCharacters(in: NSCharacterSet.whitespaces)
            }
            
            return lat+lng
        } catch  {
            //print("Error: \(error)")
            let emptyList = String()
            return emptyList
        }
    }
}

