//
//  ViewController.swift
//  Filterer
//
//  Created by Davis on 11/12/15.
//  Copyright © 2015 Davis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var filteredImage: UIImage?
    
    var avgs: [Int]?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageToggle: UIButton!
    
    @IBOutlet var secondaryMenu: UIView!
    
    @IBOutlet weak var bottomMenu: UIView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBAction func onImageToggle(sender: UIButton) {
        
        if imageToggle.selected{
            let image = UIImage(named: "scenery")!
            imageView.image = image
            imageToggle.selected = false
        }else {
            imageView.image = filteredImage
            imageToggle.selected = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getAvgs(rgbaImage: RGBAImage) -> [Int]{
        
        let pixelCount = rgbaImage.width * rgbaImage.height
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        
        for y in 0..<rgbaImage.height{
            for x in 0..<rgbaImage.width{
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        let avgRed = totalRed / pixelCount
        let avgGreen = totalGreen / pixelCount
        let avgBlue = totalBlue / pixelCount
        
        let avgs = [avgRed,avgGreen,avgBlue]
        return avgs;
    }

    
    
    func setFilterRed(avgs: [Int],rgbaImage: RGBAImage, var modifier: Int, redLevel: Int) -> UIImage{
        
        let avgRed = avgs[0]//getting red average
        
        for y in 0..<rgbaImage.height{
            for x in 0..<rgbaImage.width{
                let index = y*rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let redDelta = Int(pixel.red) - avgRed
                
                if(Int(pixel.red) < avgRed){
                    modifier = redLevel
                }
                
                pixel.red = UInt8(max(min(255,avgRed + modifier * redDelta),0))
                rgbaImage.pixels[index] = pixel
                
            }
        }
        
        let newImage = rgbaImage.toUIImage()!
        imageView.image = newImage
        return newImage;
    }
    
    
    func setFilterGreen(avgs: [Int],rgbaImage: RGBAImage, var modifier: Int, greenLevel: Int) -> UIImage{
        
        let avgGreen = avgs[2]//getting green average
        
        for y in 0..<rgbaImage.height{
            for x in 0..<rgbaImage.width{
                let index = y*rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let greenDelta = Int(pixel.green) - avgGreen
                
                if(Int(pixel.green) < avgGreen){
                    modifier = greenLevel
                }
                
                pixel.green = UInt8(max(min(255,avgGreen + modifier * greenDelta),0))
                rgbaImage.pixels[index] = pixel
                
            }
        }
        
        let newImage = rgbaImage.toUIImage()!
        imageView.image = newImage
        return newImage;
    }
    
    
    @IBAction func onFilterRed(sender: AnyObject) {
        let image = imageView.image!
        let rgbaImage = RGBAImage(image: image)!
        setFilterRed(avgs!, rgbaImage: rgbaImage, modifier: 1, redLevel: 2)
    }

    @IBAction func onFilterGreen(sender: AnyObject) {
        let image = imageView.image!
        let rgbaImage = RGBAImage(image: image)!
        setFilterGreen(avgs!, rgbaImage: rgbaImage, modifier: 1, greenLevel: 2)

    }
    
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: ["Check out our really cool app",imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    
    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: {action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: {action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {action in
            
        }))
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
        
    }
    
    func showCamera(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
        
    }
    func showAlbum(){
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    dismissViewControllerAnimated(true, completion: nil)
    if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
        imageView.image = image
        let rgbaImage = RGBAImage(image: image)!
        avgs = getAvgs(rgbaImage)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    
    @IBAction func onFilter(sender: UIButton) {
        if(sender.selected){
            hideSecondaryMenu()
            sender.selected = false
        }else{
            showSecondaryMenu()
            sender.selected = true
        }
        
    }
    
    func showSecondaryMenu(){
        
        view.addSubview(secondaryMenu)
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(bottomMenu.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(bottomMenu.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint,leftConstraint,rightConstraint,heightConstraint])
        view.layoutIfNeeded()
        
        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4){
            self.secondaryMenu.alpha = 1.0
        }
        
        
        
    }
    
    func hideSecondaryMenu(){
        UIView.animateWithDuration(0.4,animations:{
            self.secondaryMenu.alpha = 0
            }){ completed in
                if completed == true {
                    self.secondaryMenu.removeFromSuperview()
                }
        }
    }
    
   
    
}

