//
//  ViewController.swift
//  Cata Analysis
//
//  Created by Ray Xuan on 12/3/17.
//  Copyright © 2017 RayX. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct cellData {
    var cell : Int!
    var priority : Int!
    var id : String!
    var bus : String!
    var busInfo: String!
}
struct stopData {
    var id : String!
    var title : String!
    var coordinate: CLLocationCoordinate2D!
    var distance: CLLocationDistance?
    var annotation: MKAnnotation?
}

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var cellDatas = [cellData]()
    var searchResults = [cellData]()
    var favoritesDatas = [cellData]()
    var data = [[String]]()
    let getData = GetData()!
    let BLstops: Array<String> = ["1","4","51","52","54","55","148","149","159","281","283","284","285","286","287"]
    var stops = [[String]]()
    var stopsId = [String]()
    var schedule = [cell2Data]()
    var myTimer:Timer?
    var myTimer2:Timer?
    //var nameBook : [Int:String] = [:]
    var recordBook : [String:[String]] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get user's favortite routes
        //getFavoriteRoutes()
        //getFavoriteStops()
        // Get Routes Information & Setup Cells
        let date = NSDate()
        let Calender = NSCalendar.current
        
//        nameBook = [
//            1 : "E. College Ave at S. Allen Street",
//            4 : "Pattee Transit Center Eastbound",
//            51 : "Curtin Rd at Pavilion Theatre",
//            52 : "E College Ave at Atherton Hall",
//            54 : "Shortlidge Rd at White Building",
//            55 : "Pollock Rd at Millennium Science Com",
//            148 : "Curtin Rd at McCoy Natatorium",
//            149 : "Curtin Rd at Shields Building",
//            159 : "Bigler Rd at Nittany Community Center",
//            281 : "Porter Rd at Jordan East Parking",
//            282 : "Hastings Rd at Lot 83 East",
//            283 : "Hastings Rd at Forest Research Lab",
//            284 : "W College Ave at University Club",
//            285 : "N Atherton St at Walker Building",
//            286 : "Village at Penn State - Atrium Outbound",
//            287 : "Curtin Rd at Bryce Jordan Center"
//        ]
        
        for stop in BLstops {
            recordBook.updateValue([String](), forKey: stop)
        }
        
        
        getStops()
        refreshTable()
        startTimer()
        viewTimer()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Get Array of Routes From url
    func getRoutes() {
        data = getData.ofRoutes(urlString: "http://realtime.catabus.com/InfoPoint/Minimal/")
        if data.count > 3 {
            cellDatas.removeAll()
            let priority = 0
            let info = " "
            for (i,row) in data.enumerated() {
                cellDatas.append(cellData(cell: i, priority: priority, id: row[0], bus: row[1], busInfo: info))
            }
        } else {
            cellDatas.removeAll()
            for (i,row) in data.enumerated() {
                cellDatas.append(cellData(cell: i, priority: 0, id: "", bus: row[0], busInfo: ""))
            }
        }
        // Optional - Preparing for setting the favs to the top
        //cellDatas = cellDatas.sorted {$0.priority > $1.priority}
    }
    
    @objc func getStops() {
        //print("-----------------\n")
        stops = getData.ofStops(urlString: "http://realtime.catabus.com/InfoPoint/Minimal/Stops/ForRoute?routeId=55")
        if stops.count == 0 {
        } else {
            let hh2 = (Calendar.current.component(.hour, from: Date()))
            let mm2 = (Calendar.current.component(.minute, from: Date()))
            //let ss2 = (Calendar.current.component(.second, from: Date()))
            let currentTime = String(hh2)+":"+String(mm2)
            for stop in stops {
                stopsId.append(stop[0])
                schedule = getData.ofTimes(urlString: "http://realtime.catabus.com/InfoPoint/Minimal/Departures/ForStop?stopId=\(stop[0])")
                for busStop in schedule {
                    if busStop.route == "BL" && busStop.info[0] == "0m" {
                        if recordBook[stop[0]] == nil {
                            
                        } else if (recordBook[stop[0]]!.isEmpty) {
                            recordBook[stop[0]]!.append(currentTime)
                            print(1)
                        } else if recordBook[stop[0]]!.last! == currentTime {
                            
                        } else {
                            recordBook[stop[0]]!.append(currentTime)
                            print(2)
                        }
 
                    }
                }
            }
        }
        //print(stops)
    }
    
    @objc func refreshTable() {
        var text = ""
        for (stopId, times) in recordBook {
            //text += (nameBook[Int(stopId)!]! + " -")
            text += "\(stopId) -"
            for time in times {
                text += " \(time)"
            }
            text += "\n---------------------\n"
        }
        textView.text = text
    }
    
    // Start - call to refresh table
    func startTimer () {
        myTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(ViewController.getStops), userInfo: nil, repeats: true)
    }
    
    func viewTimer () {
        myTimer2 = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(ViewController.refreshTable), userInfo: nil, repeats: true)
    }
    
    // Stop - reset timer
    func stopTimer() {
        myTimer?.invalidate()
        myTimer = nil
    }
}


