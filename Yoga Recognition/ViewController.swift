//
//  ViewController.swift
//  Yoga Recognition
//
//  Created by Ozan Bilgili on 16.09.2021.
//

import AVKit
import UIKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //here is camera start up
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
       guard let captureDevice =
                AVCaptureDevice.default(for: .video) else { return }
        
        guard let input = try?
            AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
    
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        captureSession.addOutput(dataOutput)
        

    //    VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("Camera was able to capture a frame:", Date())
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        guard let model = try? VNCoreMLModel (for: YogaPoses().model)
        else { return }
        
        let request = VNCoreMLRequest(model: model)
        { (finishedReq, err) in
// check err
            
            print(finishedReq.results)
            
            guard let results = finishedReq.results as? [VNClassificationObservation]
            else {return}
            
            guard let firstObservation = results.first
            else {return}
            
            print(firstObservation.identifier, firstObservation.confidence)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        
    }
}

