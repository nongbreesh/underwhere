//
//  ProfileHeaderCell.swift
//  Quam
//
//  Created by Breeshy Sama on 1/29/2558 BE.
//  Copyright (c) 2558 Breeshy Sama. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell , UIActionSheetDelegate, PECropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

   
    @IBOutlet var btnSetting: UIButton!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblLoc: UILabel!
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var bgProfile: UIImageView!
    @IBOutlet weak var bgview: UIView!
    @IBOutlet weak var mainview: UIView!
    var userid:String!
    var isMyProfile = true
    var parent:UIViewController!
    var _IMGSIZE:CGFloat! = 120

    @IBOutlet weak var bg: UIImageView!

    class var reuseIdentifier: String {
        get {
            return "ProfileHeaderCell"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.mainview.backgroundColor =  colorize(0xEEF2F5, alpha: 1)
        //self.bgview.backgroundColor = colorize(0x916aab, alpha: 0.95)
        //self.bg.backgroundColor = colorize(0x916aab, alpha: 0.95)

      

    }


    @IBOutlet var btn_upload_image: UIButton!
    @IBOutlet var btn_setting: UIButton!


    // MARK: - PECropViewControllerDelegate methods

    func cropViewController(controller:PECropViewController ,didFinishCroppingImage croppedImage:UIImage,transform:CGAffineTransform,cropRect:CGRect)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.frame = CGRectMake(14,14, 50, 50)
        activityIndicator.startAnimating()
        self.imgProfile.addSubview(activityIndicator)

        let delay = 0.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
             self.upload_image(croppedImage,activityIndicator: activityIndicator)
        }

    }

    func upload_image(croppedImage:UIImage,activityIndicator:UIActivityIndicatorView){
        var imagecroped:UIImage!
        if croppedImage.size.width > _IMGSIZE{
            imagecroped =   RBResizeImage(croppedImage, CGSize(width: _IMGSIZE,height: _IMGSIZE))
        }
        else{
            imagecroped =   croppedImage
        }



        let imageData = UIImagePNGRepresentation(imagecroped)

        let url = "http://api.underwhere.in/api/upload_images_profile"
        if imageData != nil{
            let request = NSMutableURLRequest(URL: NSURL(string:url)!)
            var session = NSURLSession.sharedSession()

            request.HTTPMethod = "POST"

            let boundary = NSString(format: "---------------------------14737809831466499882746641449")
            let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
            // println("Content Type \(contentType)")
            request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")

            let body = NSMutableData.alloc()

            // Title
            body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"title\"\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)

            // Image
            body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"fileUpload\"; filename=\"img.png\"\\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format: "Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(imageData!)
            body.appendData(NSString(format: "\r\n--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)



            request.HTTPBody = body


            var returnData: NSData?

                returnData = NSURLConnection.sendSynchronousRequest(request, returningResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?>(), error: NSErrorPointer())


            var returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)

            dispatch_async(dispatch_get_main_queue(), {


                 let result: AnyObject? =  NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions(), error: NSErrorPointer()) as? NSDictionary


                let statusid = result?.objectForKey("StatusID") as! String
                let FileName = result?.objectForKey("FileName") as! String
                if(statusid == "1"){



                    let url = NSURL(string:"http://api.underwhere.in/api/update_user_image")
                    let request = NSMutableURLRequest(URL:url!)
                    request.HTTPMethod = "POST"


                    let postString = "userid=\(self.userid)&user_image=\(FileName)"
                    request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)

                    var returnData: NSData?

                        returnData =   NSURLConnection.sendSynchronousRequest(request, returningResponse: AutoreleasingUnsafeMutablePointer<NSURLResponse?>(), error: NSErrorPointer())



                    let task : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) in

                        if(error == nil){
                            dispatch_async(dispatch_get_main_queue(), {

                                let postresult: AnyObject? =  NSJSONSerialization.JSONObjectWithData(returnData!, options: NSJSONReadingOptions(), error: NSErrorPointer())

                                print(postresult)
                                let rs = postresult?.objectForKey("result")  as! Int
                                if rs == 1 {
                                    let imageCache:SDImageCache  = SDImageCache.sharedImageCache()
                                    imageCache.clearMemory()
                                    imageCache.cleanDisk()
                                    let img = NSURL(string: "http://api.underwhere.in/public/uploads/user_img/\(FileName)");
                                    self.imgProfile.sd_setImageWithURL(img)
                                    self.imgProfile.layer.cornerRadius =   self.imgProfile.frame.size.width / 2
                                    self.imgProfile.clipsToBounds = true
                                    self.imgProfile.layer.borderWidth = 2
                                    self.imgProfile.layer.borderColor = colorize(0xFFFFFF, alpha: 1).CGColor

                                    activityIndicator.removeFromSuperview()
                                }
                                else{
                                    activityIndicator.removeFromSuperview()
                                }
                                

                            })
                            
                        }
                        
                    })
                    task.resume()
                    
                }
                else{
                }
                
            })
            
            
        }
        
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

    }

    func cropViewControllerDidCancel(controller:PECropViewController)
    {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        controller.dismissViewControllerAnimated(true, completion: nil)

    }

    @IBAction func btn_upload_image(sender: AnyObject) {

        let actionSheet:UIActionSheet  = UIActionSheet()
        actionSheet.delegate = self

        actionSheet.addButtonWithTitle("Photo Album")
        if  UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            actionSheet.addButtonWithTitle("Camera")
        }
        actionSheet.addButtonWithTitle("Cancel")
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1


        actionSheet.showFromToolbar((self.parent.navigationController?.toolbar)!)

    }

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int){
        let buttonTitle:NSString =  actionSheet.buttonTitleAtIndex(buttonIndex)
        if buttonTitle.isEqual("Photo Album") {
            self.openPhotoAlbum()
        } else if  buttonTitle.isEqual("Camera"){
            self.showCamera()
        }
    }


    func showCamera()
    {
        let controller:UIImagePickerController  = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = UIImagePickerControllerSourceType.Camera


        self.parent.presentViewController(controller, animated: true, completion: nil)
    }

    func openPhotoAlbum()
    {

        let controller:UIImagePickerController  = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary

        self.parent.presentViewController(controller, animated: true, completion: nil)

    }

    // MARK:  -  UIImagePickerControllerDelegate methods

    /*
    Open PECropViewController automattically when image selected.
    */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {

        let img:UIImage = info["UIImagePickerControllerOriginalImage"] as! UIImage!
        let image:UIImage = img

        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.openEditor(image)
        })

        //        self.imageView.image   = image;
        //        self.imageView.hidden = true

    }

    @IBAction func openEditor(image: UIImage) {
        let controller:PECropViewController  = PECropViewController()
        controller.delegate = self;
        controller.image = image
        controller.toolbarHidden = true
        
        
        let image:UIImage = image
        let width:CGFloat = image.size.width
        let height:CGFloat = image.size.height
        let length:CGFloat = min(width, height)
        controller.imageCropRect = CGRectMake((width - length) / 2,
            (height - length) / 2,
            length,
            length);
        
        let navigationController:UINavigationController =  UINavigationController(rootViewController: controller)
        
        
        self.parent.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
