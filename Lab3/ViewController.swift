//
//  ViewController.swift
//  Lab3
//
//  Created by Yuan on 11/1/15.
//  Copyright © 2015 Yuan Cao. All rights reserved.
//

import UIKit

// Building Info Dictionaries
let buildingsInfo: [String: String] = [
    "King Library": "Dr. Martin Luther King, Jr. Library, 150 East San Fernando Street, San Jose, CA 95112",
    "Engineering Building": "San José State University Charles W. Davidson College of Engineering, 1 Washington Square, San Jose, CA 95112",
    "Yoshihiro Uchida Hall": "Yoshihiro Uchida Hall, San Jose, CA 95112",
    "Student Union": "Student Union Building, San Jose, CA 95112",
    "BBC": "Boccardo Business Complex, San Jose, CA 95112",
    "South Parking Garage": "San Jose State University South Garage, 330 South 7th Street, San Jose, CA 95112"
]

let myLocation: [String: String] = ["latitude": "", "longitude": ""]

class ViewController: UIViewController, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var buildingSearchBar: UISearchBar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var introLabel: UILabel!
    
    // Scroll map view
    var imageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]         // re-adjusts size when rotated
        
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
        let alpha: CGFloat = 0.4
        let cornerRadius: CGFloat = 5.0
        let button = UIButton()
        button.backgroundColor = UIColor.greenColor()
        button.alpha = alpha
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.greenColor().CGColor
        button.layer.cornerRadius = cornerRadius
        
        var buildingName: String = ""
//        print(tappedCGPoint)
        
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
            highligtBuilding(buildingName)
        }
    }
    
    // Highlight buildings
    func highligtBuilding(buildingName: String) {
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
            highligtBuilding(searchText)
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

