//
//  ViewController.swift
//  Lab3
//
//  Created by Yuan on 11/1/15.
//  Copyright © 2015 Yuan Cao. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var buildingSearchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // Building Info Dictionaries
    let buildingsInfo: [String: String] = [
        "King Library": "Dr. Martin Luther King, Jr. Library, 150 East San Fernando Street, San Jose, CA 95112",
        "Engineering Building": "San José State University Charles W. Davidson College of Engineering, 1 Washington Square, San Jose, CA 95112",
        "Yoshihiro Uchida Hall": "Yoshihiro Uchida Hall, San Jose, CA 95112",
        "Student Union": "Student Union Building, San Jose, CA 95112",
        "BBC": "Boccardo Business Complex, San Jose, CA 95112",
        "South Parking Garage": "San Jose State University South Garage, 330 South 7th Street, San Jose, CA 95112"
    ]
    
    // Building Latitude and Longitude Dictionaries
    let buildingLocation: [String: String] = [
        "King Library": "37.3354376,-121.8865002",
        "Engineering Building": "37.3365515,-121.8823486",
        "Yoshihiro Uchida Hall": "37.333624,-121.8836218",
        "Student Union": "37.3362474,-121.883730",
        "BBC": "37.336649,-121.878554",
        "South Parking Garage": "37.333117,-121.880721"
    ]
    var distance_text: String!
    var duration_text: String!
    
    // Location Manager
    var locationManager: CLLocationManager!
    var location: CLLocation!
    // Scroll map view
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        checkCoreLocationPermission()
        
        // Tap
        tapGesture()
        
        scrollView.delegate = self
        buildingSearchBar.delegate = self

        // imageView
        imageView.frame = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height)
        let image = UIImage(named: "sjsumap")
        imageView.image = image
        imageView.userInteractionEnabled = true
        imageView.contentMode = UIViewContentMode.Center
        imageView.frame = CGRectMake(0, 0, image!.size.width, image!.size.height)
        
        // scrollView
        scrollView.addSubview(imageView)
        scrollView.contentSize = image!.size
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]         // re-adjust size when rotated
        
        // Default image offset
        scrollView.contentOffset = CGPoint(x: 200, y: 200)
        
        // Scaling
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleHeight, scaleWidth)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 1.0
        
        // Default zoom scale when first loading the app
        scrollView.zoomScale = 0.53
        
        // Put content in the center of scrollView
        centerScrollViewContents()
    }
    
    /*---------------------------------------------------------------------------*/
    // Distance
    func calculateDistance(buildingName: String) {
        let origins: String = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        print("origins ======> ", origins)
        let destinations: String = buildingLocation[buildingName]!
        
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/distancematrix/json?origins=" + origins + "&destinations=" + destinations + "&mode=walking&key=AIzaSyDXKCjFiS--8xJAZ6OxHnGnjDvr3_acT7o")
        print("url ======> ", url)
//
        let sharedSession = NSURLSession.sharedSession()
        let dataTask = sharedSession.dataTaskWithURL(url!) { (data, response, error) -> Void in
            do {
                let jsonData: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
//                print("jsonData ======> ", jsonData)

                // Decode distance and duration from responded data package
                let row = jsonData["rows"] as! NSArray
                let elements = row[0] as! NSDictionary
                let element = elements["elements"] as! NSArray
//                print(element)
                let info = element[0] as! NSDictionary
                let distance_detail = info["distance"] as! NSDictionary
                let duration_detail = info["duration"] as! NSDictionary
                self.distance_text = distance_detail["text"] as! String
                self.duration_text = duration_detail["text"] as! String

                print("Nuilding's Name ======>", buildingName)
                print("DECODE distance ======>", self.distance_text)
                print("DECODE duration ======>", self.duration_text)
            } catch {
                print(error)
            }
        }
        
        dataTask.resume()
    }

    
    /*---------------------------------------------------------------------------*/
    // Location
    // MARK: - Location Delegate Method
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
//        print("Current location: (\(location.coordinate.latitude), \(location.coordinate.longitude))")
    }
    
    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if CLLocationManager.authorizationStatus() == .Restricted {
            print("Cannot use location!!")
        }
    }
    
    func updatingLocation(buildingName: String) {
        locationManager.startUpdatingLocation()
        calculateDistance(buildingName)
        print("Current Latitude: \(location.coordinate.latitude); Current Longitude: \(location.coordinate.longitude)")
        
//        locationManager.stopUpdatingLocation()
    }
    
    func highlightCurrentLocationOnMap() {
        let currentLocationImageView = UIImageView()
        let currentLocationImage = UIImage(named: "start")
        currentLocationImageView.image = currentLocationImage
        
        // Transfer delta latitude and longitutde to image pixel x and y
        // Top-left point of campus
        let start_pixel_x = 56.5
        let start_pixel_y = 196.5
        let start_latitude = 37.335831
//        let start_longitutde = -121.885826
        
        // Top-right point of campus
        let width_end_pixel_x = 597.5
//        let width_end_lantitude = 37.338826
//        let width_end_longitude = -121.879704
        
        let image_map_width = width_end_pixel_x - start_pixel_x
        
        // Button-left point of campus
        let height_end_pixel_y = 646.5
        let height_end_latitude = 37.331623
        
        let image_map_height = height_end_pixel_y - start_pixel_y
        
        // W/H rate
        let image_rate = image_map_width / image_map_height

        // Current Point
        let latitude = location.coordinate.latitude
        let delta_lan_rate = fabs(latitude - start_latitude) / fabs(height_end_latitude - start_latitude)
        print(delta_lan_rate)
        print(delta_lan_rate * image_map_height)
        let delta_y = delta_lan_rate * image_map_height
        let delat_x = delta_y * image_rate
        let current_pixel_y = delta_y + start_pixel_y
        let current_pixel_x = delat_x + start_pixel_x
        
        // Mark current location in image map
        currentLocationImageView.frame = CGRectMake(CGFloat(current_pixel_x - 10), CGFloat(current_pixel_y - 26), 20, 26)
        print("Current Pixel }}}}}}} (\(current_pixel_x), \(current_pixel_y))")
        
        imageView.addSubview(currentLocationImageView)
    }
  
    /*---------------------------------------------------------------------------*/
    // Tap gesture
    func tapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: "showBuildingInfo:")
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    func showBuildingInfo(tapGesture: UITapGestureRecognizer) {
        let tappedCGPoint = tapGesture.locationInView(imageView)

        markBuilding(tappedCGPoint)
    }
    
    // TODO (optinal): use global constants to mark the pixels of buildings
    func markBuilding(tappedCGPoint: CGPoint) {
        var buildingName: String = ""
        print(tappedCGPoint)
        
        if (tappedCGPoint.x > 65 && tappedCGPoint.x < 130) && (tappedCGPoint.y > 190 && tappedCGPoint.y < 280) {
            buildingName = "King Library"
            
        } else if (tappedCGPoint.x > 340 && tappedCGPoint.x < 435) && (tappedCGPoint.y > 195 && tappedCGPoint.y < 300) {
            buildingName = "Engineering Building"
            
        } else if (tappedCGPoint.x > 65 && tappedCGPoint.x < 125) && (tappedCGPoint.y > 405 && tappedCGPoint.y < 475) {
            buildingName = "Yoshihiro Uchida Hall"
            
            
        } else if (tappedCGPoint.x > 340 && tappedCGPoint.x < 450) && (tappedCGPoint.y > 305 && tappedCGPoint.y < 355) {
            buildingName = "Student Union"
            
        } else if (tappedCGPoint.x > 530 && tappedCGPoint.x < 595) && (tappedCGPoint.y > 360 && tappedCGPoint.y < 405) {
            buildingName = "BBC"
            
        } else if (tappedCGPoint.x > 200 && tappedCGPoint.x < 320) && (tappedCGPoint.y > 565 && tappedCGPoint.y < 650) {
            buildingName = "South Parking Garage"
            
        } else {
            buildingName = "Not Found"
        }
        
        if buildingName == "Not Found" {
            introLabel.text = buildingName
            buildingImageView.image = UIImage(named: "sjsu")
            removeSubviews()
            
        } else {
            introLabel.text = buildingsInfo[buildingName]
            buildingImageView.image = UIImage(named: buildingName)

            removeSubviews()
            highlightBuilding(buildingName)
            highlightCurrentLocationOnMap()
        }
    }
    
    // Highlight buildings
    func highlightBuilding(buildingName: String) {
        
        // Update current location
        updatingLocation(buildingName)
        
        // Highligt frame
        let alpha: CGFloat = 0.4
        let cornerRadius: CGFloat = 5.0
        let button = UIButton()
        button.backgroundColor = UIColor.greenColor()
        button.alpha = alpha
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.greenColor().CGColor
        button.layer.cornerRadius = cornerRadius
        
        switch buildingName {
        case "King Library":
            button.frame = CGRectMake(65, 190, (130-65), (280-190))
        case "Engineering Building":
            button.frame = CGRectMake(340, 195, (435-340), (300-195))
        case "Yoshihiro Uchida Hall":
            button.frame = CGRectMake(65, 405, (125-65), (475-405))
        case "Student Union":
            button.frame = CGRectMake(340, 305, (450-340), (355-305))
        case "BBC":
            button.frame = CGRectMake(530, 360, (595-530), (405-360))
        case "South Parking Garage":
            button.frame = CGRectMake(200, 565, (320-200), (650-565))
        default:
            break
        }
        
        centerMarkedBuilding(button)
        imageView.addSubview(button)
        
        // Update label text
        let text = "Distance and time to \(buildingName): \(distance_text), \(duration_text)"
        print("text >>>>>>>>: ", text)
        distanceLabel.text = text
    }
    
    // Remove subviews
    func removeSubviews() {
        for view in imageView.subviews { view.removeFromSuperview() }
    }
    
    /*---------------------------------------------------------------------------*/
    // Zoom
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // Center after zoomed out
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // put content in the center of scrollView
        centerScrollViewContents()
    }
    
    // Center marked building
    // |------------------------self.contentSize.width------------------------|
    //                          |-----self.width-----|
    // |-------- offset --------|
    //                                     ^ center
    func centerMarkedBuilding(button: UIButton) {
        // Zoom in to maximum
        scrollView.zoomScale = scrollView.maximumZoomScale
        
        // Set new offset according to the building position
        let buttonMiddleX = button.frame.origin.x + button.frame.width/2
        let buttonMiddleY = button.frame.origin.y + button.frame.height/2
        scrollView.contentOffset = CGPoint(x: buttonMiddleX - 175, y: buttonMiddleY - 125)
    }
    
    // Set smaller content of image to the center of scrollView
    func centerScrollViewContents() {
        let boundSize = scrollView.bounds.size
        var contentFrame = imageView.frame
        
        if contentFrame.size.width < boundSize.width {
            contentFrame.origin.x = (boundSize.width - contentFrame.size.width) / 2
        } else {
            contentFrame.origin.x = 0
        }
        
        if contentFrame.size.height < boundSize.height {
            contentFrame.origin.y = (boundSize.height - contentFrame.size.height) / 2
        } else {
            contentFrame.origin.y = 0
        }
        
        imageView.frame = contentFrame
    }

    /*---------------------------------------------------------------------------*/
    // Search function
    func searchBarSearchButtonClicked(buildingSearchBar: UISearchBar) {
        // Dismiss the keyboard
        buildingSearchBar.resignFirstResponder()
        removeSubviews()
        
        let searchText = buildingSearchBar.text as String!
        if buildingsInfo[searchText] != nil {
            introLabel.text = buildingsInfo[searchText]
            buildingImageView.image = UIImage(named: searchText)
            highlightBuilding(searchText)
            highlightCurrentLocationOnMap()
        } else {
            introLabel.text = "Not Found"
        }
    }
    
    func searchBarCancelButtonClicked(buildingSearchBar: UISearchBar) {
        // Dismiss the keyboard
        buildingSearchBar.resignFirstResponder()
        removeSubviews()
        
        buildingSearchBar.text = ""
        introLabel.text = "Address"
        buildingImageView.image = UIImage(named: "sjsu")
    }
    
    @IBAction func refreshButtonClicked(sender: AnyObject) {
        // Dismiss the keyboard
        buildingSearchBar.resignFirstResponder()
        removeSubviews()
        
        buildingSearchBar.text = ""
        introLabel.text = "Address"
        buildingImageView.image = UIImage(named: "sjsu")

    }
}

