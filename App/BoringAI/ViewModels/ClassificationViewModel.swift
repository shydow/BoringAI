//
//  ClassificationViewModel.swift
//  BoringAI
//
//  Created by Shydow Lee on 2020/1/2.
//  Copyright © 2020 Shydow Lee. All rights reserved.
//

import Foundation
import AVKit
import Vision

class ClassificationViewModel: NSObject, ObservableObject {
    @Published var result = ClassificationResult(identity: "undefined", confidance: 0.0)
    @Published var preview = AVCaptureVideoPreviewLayer()
    
    var timer: Timer = Timer.init()
    
    
    
    func startClassify() {
        print("start...")
     
//        timer = Timer.init(timeInterval: 1, repeats: true, block: { timer in
//            self.result.confidance += 1
//        })
//        RunLoop.current.add(timer, forMode: .default)
//        timer.fire()
        
        validPrivilege()
        setupSession()
        
        captureSession?.startRunning()
    }
    
    func stopClassify() {
        result.identity = "undefined"
        result.confidance = 0.0
        
//        timer.invalidate()
        captureSession?.stopRunning()
    }
    
    private var captureSession: AVCaptureSession?
    
    private func validPrivilege() {
        var allowedAccess = false
        let blocker = DispatchGroup()
        blocker.enter()
        AVCaptureDevice.requestAccess(for: .video) { flag in
            allowedAccess = flag
            blocker.leave()
        }
        blocker.wait()

        if !allowedAccess {
            print("!!! NO ACCESS TO CAMERA")
            return
        }
    }
    
    private func setupSession() {
        let session = AVCaptureSession()
        session.beginConfiguration()

        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
            for: .video, position: .unspecified) //alternate AVCaptureDevice.default(for: .video)
        guard videoDevice != nil, let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!), session.canAddInput(videoDeviceInput) else {
            print("!!! NO CAMERA DETECTED")
            return
        }
        session.addInput(videoDeviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(dataOutput)

        session.commitConfiguration()
        self.captureSession = session
        
        preview = AVCaptureVideoPreviewLayer(session: captureSession!)
    }
}

extension ClassificationViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            
            guard let firstObservation = results.first else { return }
            
            print(firstObservation.identifier, firstObservation.confidence)
            
            DispatchQueue.main.async {
//                self.updateLabel(content: "\(firstObservation.identifier) \(firstObservation.confidence * 100)")
                self.result.identity = firstObservation.identifier
                self.result.confidance = firstObservation.confidence
            }
            
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
