//
//  MyMenuTableViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

class AppMenuTableViewController: UITableViewController,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet var CustomMenu: UITableView!
    var selectedMenuItem : Int = 0
    var items: [String] = ["We", "Heart", "Swift"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getdata()
        self.CustomMenu?.delegate = self
        self.CustomMenu?.dataSource = self
        //println(self.CustomMenu)
        
        let nibName = UINib(nibName: "CustomViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "MENUCELL")

        
        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(30, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)
    }
    
    func getdata(){
        HTTPGet("http://marketbike.zoaish.com/api/get_category") {
            (data: String, error: String?) -> Void in
            if error != nil {
                println(error)
            } else {
               //println(data)
                var jsdata = data.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
                var localError: NSError?
                var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(jsdata!, options: NSJSONReadingOptions.MutableContainers, error: &localError)

                if let dict = json as? [String: AnyObject] {
                    if let result = dict["result"] as? [AnyObject] {
                         //println(result)
                        for dict2 in result {
                            let id = dict2["ID"]
                            let title = dict2["Headline"]
                            let image = dict2["Thumbnail_Image"]
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCellWithIdentifier("MENUCELL", forIndexPath: indexPath) as CustomViewCell
        cell.backgroundColor = UIColor.clearColor()
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height))
        selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        let thumb = UIImage(named: "pin.png")
        cell.imgThumb.image = thumb
        let statusicon = UIImage(named: "online_icon.png")
        cell.imgStatus.image = statusicon
        cell.lbltitle.text = self.items[indexPath.row]
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        println("did select row: \(indexPath.row)")
        
        if (indexPath.row == selectedMenuItem) {
            return
        }
        selectedMenuItem = indexPath.row
        
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController : UIViewController
        switch (indexPath.row) {
        case 0:
            //destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController1") as UIViewController
            break
        case 1:
            //destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController2") as UIViewController
            break
        case 2:
            //destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController3") as UIViewController
            break
        default:
            //destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController4") as UIViewController
            break
        }
        //sideMenuController()?.setContentViewController(destViewController)
         toggleSideMenuView()
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
