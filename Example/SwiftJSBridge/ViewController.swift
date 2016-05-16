//
//  ViewController.swift
//  SwiftJSBridge
//
//  Created by xiongxiong on 05/05/2016.
//  Copyright (c) 2016 xiongxiong. All rights reserved.
//

import UIKit
import WebKit
import ObjectMapper
import SwiftJSBridge

typealias Handler = SwiftJSBridge.Handler
typealias HandlerInvocation = SwiftJSBridge.HandlerInvocation

class ViewController: UITableViewController {

    private var webView: WKWebView = WKWebView(frame: CGRectZero, configuration: WKWebViewConfiguration())
    private var bridge: SwiftJSBridge?
    private var messagesFromJS: Array<String> = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseId")
        webView.navigationDelegate = self
        bridge = SwiftJSBridge.bridge(webView: webView, delegate: self)
        
        let htmlPath = NSBundle.mainBundle().pathForResource("test", ofType: "html")!
        let htmlStr = try! String(contentsOfFile: htmlPath, encoding: NSUTF8StringEncoding)
        webView.loadHTMLString(htmlStr, baseURL: NSURL(fileURLWithPath: htmlPath))
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.font = UIFont(name: cell.textLabel!.font.fontName, size: 11)
        cell.textLabel?.text = self.messagesFromJS[indexPath.row]
        cell.textLabel?.numberOfLines = 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesFromJS.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("reuseId", forIndexPath: indexPath) as UITableViewCell
        return cell
    }
}

extension ViewController {
    func printMessage(message: String) {
        self.messagesFromJS.append(message)
        self.tableView.reloadData()
    }
    
    func callJSHandlers() {
        weak var safeMe = self
        
        bridge?.callJSHandler(HandlerInvocation(name: "swiftCallWithNoData")) { (data: AnyObject?) in
            safeMe?.printMessage("js_callback -- 1 -- " + (data as! String))
        }
        bridge?.callJSHandler(HandlerInvocation(name: "swiftCallWithStringData",data: "Swift says: swiftCallWithStringData called.".debugDescription)) { (data: AnyObject?) in
            safeMe?.printMessage("js_callback -- 2 -- " + (data as! String))
        }
        bridge?.callJSHandler(HandlerInvocation(name: "swiftCallWithIntegerData",data: 4.description)) { (data: AnyObject?) in
            safeMe?.printMessage("js_callback -- 3 -- " + String(format: "Swift says: swiftCallWithIntegerData called: %i.", data as! Int))
        }
        bridge?.callJSHandler(HandlerInvocation(name: "swiftCallWithDoubleData",data: 8.32743.description)) { (data: AnyObject?) in
            safeMe?.printMessage("js_callback -- 4 -- " + String(format: "Swift says: swiftCallWithDoubleData called: %.9f.", data as! Double))
        }
        bridge?.callJSHandler(HandlerInvocation(name: "swiftCallWithArrayData",data: "[\"swift call with array data (1)\", \"swift call with array data (2)\"]")) { (data: AnyObject?) in
            let array = data as! [String]
            array.forEach({ (message) in
                safeMe?.printMessage("js_callback -- 5 -- " + message)
            })
        }
        bridge?.callJSHandler(HandlerInvocation(name: "swiftCallWithDictionaryData",data: "{\"method\": \"Method_Start\", \"message\": \"swift call with dictionary\"}")) { (data: AnyObject?) in
            let dict = data as! Dictionary<String, String>
            safeMe?.printMessage("js_callback -- 6 -- " + dict["message"]!)
        }
        bridge?.callJSHandler(HandlerInvocation(name: "swiftCallWithDictionaryData",data: JSModel(message: "My JSModel").toJSONString()!)) { (data: AnyObject?) in
            let dict = data as! Dictionary<String, String>
            safeMe?.printMessage("js_callback -- 7 -- " + dict["message"]!)
        }
    }
}

extension ViewController: SwiftJSBridgeDelegate {
    func swiftHandlers() -> [Handler] {
        return [
            Handler(name: "noDataHandler", closure: { [unowned self] (data: AnyObject?) in
                self.printMessage("1 -- JS says: Calling noDataHandler.")
            }),
            Handler(name: "stringDataHandler", closure: { [unowned self] (data: AnyObject?) in
                self.printMessage("2 -- " + (data as! String))
            }),
            Handler(name: "integerDataHandler", closure: { [unowned self] (data: AnyObject?) in
                self.printMessage(String(format: "3 -- %@ %i.", "JS says: Calling integerDataHandler:", data as! Int))
            }),
            Handler(name: "doubleDataHandler", closure: { [unowned self] (data: AnyObject?) in
                self.printMessage(String(format: "4 -- %@ %.9f", "JS says: Calling doubleDataHandler:", data as! Double))
            }),
            Handler(name: "arrayDataHandler", closure: { [unowned self] (data: AnyObject?) in
                (data as! Array<String>).forEach({ (message) in
                    self.printMessage("5 -- " + message)
                })
            }),
            Handler(name: "dictionaryDataHandler", closure: { [unowned self] (data: AnyObject?) in
                let dataDic = data as! Dictionary<String, String>
                self.printMessage("6 -- " + dataDic["message"]!)
            }),
            Handler(name: "callBackToJS", closure: { [unowned self] (data: AnyObject?) in
                let dataDic = data as! Dictionary<String, String>
                self.printMessage("7 -- " + dataDic["message"]!)
                self.bridge?.callJSHandler(HandlerInvocation(name: "swiftCallBackJSFunction",data: "{\"message\": \"callBackToJS_callback\"}"), callback: { [unowned self] (data) in
                    let dataDic = data as! Dictionary<String, String>
                    self.printMessage("7 -- " + dataDic["message"]! + " -- callback")
                })
            }),
        ]
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        callJSHandlers()
    }
}
