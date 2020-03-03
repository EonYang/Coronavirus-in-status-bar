//
//  AppDelegate.swift
//  Cov_in_Status_Bar
//
//  Created by yangyang on 2/23/20.
//  Copyright © 2020 yangyang. All rights reserved.
//

import Cocoa
import SwiftCSV
//import Foundation
import SwiftDate
//import WebKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?
    @IBOutlet weak var secondMenuItem: NSMenuItem?
    
    let global:Bool = false
    let regions = ["China","Taiwan","Hong Kong","Macau"]
    let refreshEvery:Int = 60
    
    var statusItem: NSStatusItem?
    var customView: CustomView?
    
    var dataString:String = ""
    var lastDay:String = ""
    
    let urlConfirmed = URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")
    
    let urlDead = URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv")
    
    let urlRecovered = URL(string: "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        let itemImage = NSImage(named: "status_bar_icon")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        
        if let menu = menu {
            statusItem?.menu = menu
            menu.delegate = self
        }
        
        if let item = firstMenuItem {
            customView = CustomView(frame: NSRect(x: 0.0, y: 0.0, width: 240.0, height: 120.0))
            item.view = customView
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Timer.scheduledTimer(withTimeInterval: TimeInterval(self.refreshEvery), repeats: true) { timer in
            print("auto refresh")
            self.updateNumbers ()
        }
        updateNumbers ()
    }
    
    @objc func updateNumbers () {
        
        getSum(url: urlConfirmed!, completionHandeler: { result, date in
            self.secondMenuItem?.title = "updating..."
            let rString: String? = String(result!)
            print(rString!)
            self.customView?.labelConfirmed.stringValue = rString!
            self.setLastUpdateDate(date, self.secondMenuItem)
        })
        getSum(url: urlDead!, completionHandeler: { result, date in
            let rString: String? = String(result!)
            print(rString!)
            self.customView?.labelDead.stringValue = rString!
        })
        getSum(url: urlRecovered!, completionHandeler: { result , date in
            let rString: String? = String(result!)
            print(rString!)
            self.customView?.labelRecovered.stringValue = rString!
        })
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {}
    
    func setLastUpdateDate(_ lastDay:String!,_ menuItem: NSMenuItem!) {
        let now = Date()
        menuItem.title = "Till " + lastDay + ", updated " + now.toRelative(style: RelativeFormatter.defaultStyle(), locale: Locales.english)
    }
    
    func getSum(url:URL, completionHandeler: @escaping (_ sum: Int?, _ lastDay: String?) -> Void ){
        var r: Int? = 0
        var lastDay: String?
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let dataString = String(data: data, encoding: .utf8)!
            
            do {
                let csv: CSV = try CSV(string: dataString)
                lastDay = csv.header.last!
                for line in csv.namedRows {
                    if self.global {
                        r! += Int(line[lastDay!]!)!
                    }
                    else if  self.regions.contains(where: line["Country/Region"]!.contains)
                    {
                        r! += Int(line[lastDay!]!)!
                    }
                }
                completionHandeler(r!, lastDay!)
                
            } catch let parseError as CSVParseError {
                print(parseError)
            } catch {
                // Catch errors from trying to load files
            }
        }
        task.resume()
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        self.updateNumbers()
        
    }
    func menuDidClose(_ menu: NSMenu) {}
    
}

