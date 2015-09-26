//
//  ViewController.swift
//  QrReaderGenerator
//
//  Created by ak2g on 9/26/15.
//  Copyright © 2015 ak2g. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeframeView:UIView?
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var CancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CancelButton.hidden = true
        
    }
    
    @IBAction func ScanMe(sender: AnyObject) {
        self.imgView.hidden=true
        textField.text=""

        textField.backgroundColor=UIColor.clearColor()

        
        CancelButton.hidden = false
        textField.hidden = false
        
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error:NSError?
        let input: AnyObject!
        
        do {
            
            input = try AVCaptureDeviceInput(device: captureDevice)
            
        } catch let error1 as NSError {
            
            error = error1
            input = nil
            
        }
        
        if (error != nil) {
            
            print("\(error?.localizedDescription)")
            return
            
        }
        
        captureSession = AVCaptureSession()
        captureSession?.addInput(input as! AVCaptureInput)
        
        let captureMetadatOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadatOutput)
        
        captureMetadatOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        captureMetadatOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession?.startRunning()
        //Bring Text and button to front
        view.bringSubviewToFront(textField)
        view.bringSubviewToFront(CancelButton)
        
        qrCodeframeView = UIView()
        qrCodeframeView?.layer.borderColor = UIColor.greenColor().CGColor
        qrCodeframeView?.layer.borderWidth = 2
        view.addSubview(qrCodeframeView!)
        view.bringSubviewToFront(qrCodeframeView!)
        
        
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            
            qrCodeframeView?.frame = CGRectZero
            textField.text = "No QR code detected"
            return
            
        }
        
        
        let metadateObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadateObj.type == AVMetadataObjectTypeQRCode {
            
            let BarcodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadateObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeframeView?.frame = BarcodeObject.bounds
            
            if metadateObj.stringValue != nil {
                
                textField.text = metadateObj.stringValue
                
                captureSession?.stopRunning()
                
            }
            
            
        }
        
        
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        textField.resignFirstResponder()
    }
    
    
    @IBAction func Cancel(sender: AnyObject) {
        
        CancelButton.hidden = true
        textField.backgroundColor=UIColor.lightGrayColor()
        captureSession?.stopRunning()
        qrCodeframeView?.removeFromSuperview()
        videoPreviewLayer?.removeFromSuperlayer()
        self.imgView.hidden=true
        textField.text=""
    }
    
    @IBAction func generate(sender: AnyObject) {
        
        if textField.text != ""{
        self.imgView.hidden=false
            
        
        self.imgView.image = generateCode()
            textField.text=""

        }else{
            
            let alert = UIAlertController(title: "Alert", message: "Please Type something to generate Qrode", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
    }
    
    
    
    
    
    func generateCode() -> UIImage {
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        
        let inputData = textField.text!.dataUsingEncoding(NSUTF8StringEncoding)
        filter!.setValue("H", forKey:"inputCorrectionLevel")
        filter!.setValue(inputData, forKey:"inputMessage")
        
        
        let outputImage = filter!.outputImage
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(outputImage!, fromRect:outputImage!.extent)
        
        let image = UIImage(CGImage:cgImage, scale:0, orientation:UIImageOrientation.Up)
        let resized = resizeImage(image, withQuality: .None, rate:5)
        return resized
    }
    
    func resizeImage(image: UIImage, withQuality quality: CGInterpolationQuality, rate: CGFloat) -> UIImage {
        let width = image.size.width * rate
        let height = image.size.height * rate
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), true, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, quality)
        image.drawInRect(CGRectMake(0, 0, width, height))
        
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return resized
    }
    
    
    
}