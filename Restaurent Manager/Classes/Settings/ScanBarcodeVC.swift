//
//  ScanBarcodeVC.swift
//  Restaurent Manager
//


import UIKit
import AVFoundation

class ScanBarcodeVC: Main, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet var viewPreview: UIView!
    
    
    let systemSoundId : SystemSoundID = 1016
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isReading: Bool = false
    var barcodeData : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        lblTitle.text = Language.SCANNER
        lblDesc.text = Language.APPROACH_QR_CODE
        
        captureSession = nil;
        
        DispatchQueue.main.async {
            if !self.isReading {
                if (self.startReading()) {
                }
            }
            else {
                self.stopReading()
            }
            self.isReading = !self.isReading
        }
    }
    
    @IBAction func btnSideMenu_Action(_ sender: Any) {
        toggleSideMenuView()
    }
    
    @IBAction func scanBarCodeAction(_ sender: Any) {
        
        //self.sendBarcodeService()
        
        if !isReading {
            if (self.startReading()) {
                
            }
        }
        else {
            stopReading()
        }
        isReading = !isReading
    }
    
    func startReading() -> Bool {
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        if let captureDevice = captureDevice {
            do {
                captureSession = AVCaptureSession()
                
                // CaptureSession needs an input to capture Data from
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession?.addInput(input)
                
                // CaptureSession needs and output to transfer Data to
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession?.addOutput(captureMetadataOutput)
                
                //We tell our Output the expected Meta-data type
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = [.code128, .qr,.ean13, .ean8, .code39, .upce, .aztec, .pdf417] //AVMetadataObject.ObjectType
                
                captureSession?.startRunning()
                
                //The videoPreviewLayer displays video in conjunction with the captureSession
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer.frame = viewPreview.layer.bounds
                viewPreview.layer.addSublayer(videoPreviewLayer)
            }
            catch {
                print("Error")
            }
        }
        
        return true
    }
    
    @objc func stopReading() {
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer.removeFromSuperlayer()
        
        print("BarCode Scan : \(self.barcodeData)")
        if barcodeData != ""{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toAddPoint", sender: nil)
            }
        }       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddPoint"{
            let vc = segue.destination as! AddPointVC
            vc.barCodeData = self.barcodeData
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            print("no objects returned")
            return
        }
        
        let metaDataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        guard let StringCodeValue = metaDataObject.stringValue else {
            return
        }
        
        guard (videoPreviewLayer?.transformedMetadataObject(for: metaDataObject)) != nil else {
            return
        }
        
        self.barcodeData = StringCodeValue
        
        if self.barcodeData != ""{
            AudioServicesPlayAlertSound(systemSoundId)
            stopReading()
            isReading = false;
        }
        
        
//        if URL(string: StringCodeValue) != nil {
//
//            self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
//            isReading = false;
//        }
    }

}
