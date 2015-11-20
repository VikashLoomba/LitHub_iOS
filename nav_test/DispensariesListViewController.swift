//
//  DispensariesViewController.swift
//  nav_test
//
//  Created by mac on 9/14/15.
//  Copyright © 2015 mac. All rights reserved.
//

import UIKit
import Alamofire


class DispensariesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Search bar variable


    @IBOutlet weak var searchBar: UISearchBar!

    
    
    //Table Variables
    @IBOutlet weak var tableView: UITableView!
    
    
    var dispensaries = [mkDispensary]()
    var filteredDispensaries = [mkDispensary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestDispensaries()
        self.searchBar.sizeToFit()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData();
        print("in the list view controller")
        
    }
    
    func requestDispensaries() {
        let string = "http://getlithub.herokuapp.com/dispensaries"
        //print(string)
        Alamofire.request(.GET, string)
            .responseJSON { response in
                if response.result.isSuccess {
                    //case .Success(let data):
                    let arrayOfDispensaries = JSON(response.result.value!)
                    for var i = 0; i < arrayOfDispensaries.count; ++i {
                        let dispensaryId = arrayOfDispensaries[i]["id"].int
                        let dispensaryName = arrayOfDispensaries[i]["name"].string
                        let dispensaryLat = arrayOfDispensaries[i]["lat"].double
                        let dispensaryLng = arrayOfDispensaries[i]["lng"].double
                        let dispensaryAdd = arrayOfDispensaries[i]["address"].string
                        let dispensaryState = arrayOfDispensaries[i]["State"].string
                        let dispensaryCity = arrayOfDispensaries[i]["City"].string
                        let dispensaryPhone = arrayOfDispensaries[i]["phone"].string
                        let dispensaryLogo = arrayOfDispensaries[i]["logo"].string
                        let dispensary = mkDispensary(title: dispensaryName!, id: dispensaryId!, name: dispensaryName!, address: dispensaryAdd!, city: dispensaryCity!, latitude: dispensaryLat!, longitude: dispensaryLng!, state: dispensaryState!, phone: dispensaryPhone!, distance: 0.0, logo: dispensaryLogo!)
                        dispensary.latitude = dispensaryLat!
                        dispensary.longitude = dispensaryLng!
                        self.dispensaries.append(dispensary)
                    }
                    
                    self.tableView.reloadData()
                    
                } else {
                    //case .Failure(_, let error):
                    print("Request failed with error \(response.result.error)")
                    
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseJSON(inputData: NSData) -> NSArray? {
        do {
            var arrOfObjects = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            return arrOfObjects
        } catch {
            print(error)
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.dispensaries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : DispensaryCell
        cell = tableView.dequeueReusableCellWithIdentifier("DispensaryCell", forIndexPath: indexPath) as! DispensaryCell
        cell.dispensaryName!.text = dispensaries[indexPath.row].name
        cell.dispensaryPhone!.text = dispensaries[indexPath.row].phone
        cell.dispensaryStreetAddress!.text = dispensaries[indexPath.row].address
        cell.dispensaryCityState!.text = dispensaries[indexPath.row].city.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) + ", " + dispensaries[indexPath.row].state
        let request: NSURLRequest = NSURLRequest(URL: NSURL(string: dispensaries[indexPath.row].logo)!)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                // Convert the downloaded data in to a UIImage object
                // Update the cell
                dispatch_async(dispatch_get_main_queue(), {
                    if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                        cell.dispensaryLogo.image = UIImage(data: data!)
                    }
                })
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("ShowMenu", sender: self.tableView.cellForRowAtIndexPath(indexPath))
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let menuViewController = segue.destinationViewController as! MenuViewController
        if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
            menuViewController.dispensary = dispensaries[indexPath.row]
        }
        
    }


    
    
    
}