//
//  AppDelegate.swift
//  Cov_in_Status_Bar
//
//  Created by yangyang on 2/23/20.
//  Copyright © 2020 yangyang. All rights reserved.
//

import Cocoa
import SwiftCSV
//import WebKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?
    
    var statusItem: NSStatusItem?
    var customView: CustomView?
    
    var dataString:String = ""
    
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
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            print("auto refresh")
            self.updateNumbers ()
        }
        updateNumbers ()
    }
    
    @objc func updateNumbers () {
        getSum(url: urlConfirmed!, completionHandeler: { result in
            let rString: String? = String(result!)
            print(rString!)
            self.customView?.labelConfirmed.stringValue = rString!
        })
        getSum(url: urlDead!, completionHandeler: { result in
            let rString: String? = String(result!)
            print(rString!)
            self.customView?.labelDead.stringValue = rString!
        })
        getSum(url: urlRecovered!, completionHandeler: { result in
            let rString: String? = String(result!)
            print(rString!)
            self.customView?.labelRecovered.stringValue = rString!
        })
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {}
    
    func getSum(url:URL, completionHandeler: @escaping (_ sum: Int?) -> Void ){
        var r: Int? = 0
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let dataString = String(data: data, encoding: .utf8)!
            
            do {
                let csv: CSV = try CSV(string: dataString)
                let lastDay = csv.header.last
                print(lastDay!)
                for line in csv.namedRows {
                    if line["Country/Region"]!.contains("China"){
                        r! += Int(line[lastDay!]!)!
                    }
                }
                completionHandeler(r!)
                
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

