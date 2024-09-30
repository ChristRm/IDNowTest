//
//  CameraService.swift
//  IDNowTest
//
//  Created by Kristian Rusyn on 29/09/2024.
//

import Foundation
import AVFoundation
import UIKit

protocol CameraService {
    func setupCameraStream(view: UIView) throws
    func capturePhoto(imageClosure: @escaping (UIImage?, Error?) -> Void)
}

class CameraServiceImpl: NSObject, CameraService {
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var capturePhotoOutput: AVCapturePhotoOutput!
    
    private var imageClosure: ((UIImage?, Error?) -> Void)?
    
    func setupCameraStream(view: UIView) throws {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }
        
        let input = try AVCaptureDeviceInput(device: backCamera)
        captureSession.addInput(input)
        
        capturePhotoOutput = AVCapturePhotoOutput()
        captureSession.addOutput(capturePhotoOutput)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        captureSession.startRunning()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if #available(iOS 16.0, *) {
                let activeFormat = backCamera.activeFormat
                let maxDimensions = activeFormat.formatDescription.dimensions
                self.capturePhotoOutput.maxPhotoDimensions = CMVideoDimensions(width: maxDimensions.width, height: maxDimensions.height)
            }
        }
        
        print("Capture session started successfully")
    }
    
    func capturePhoto(imageClosure: @escaping (UIImage?, Error?) -> Void) {
        self.imageClosure = imageClosure
        let settings = AVCapturePhotoSettings()

        if #available(iOS 16.0, *) {
            if let deviceInput = capturePhotoOutput.connections.first?.inputPorts.first?.input as? AVCaptureDeviceInput {
                let activeFormat = deviceInput.device.activeFormat
                let maxDimensions = activeFormat.formatDescription.dimensions
                settings.maxPhotoDimensions = CMVideoDimensions(width: maxDimensions.width, height: maxDimensions.height)
            }
        } else {
            settings.isHighResolutionPhotoEnabled = true
        }

        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
}


extension CameraServiceImpl: AVCapturePhotoCaptureDelegate {
    @objc(captureOutput:didFinishProcessingPhoto:error:) func photoOutput(_ output: AVCapturePhotoOutput,
                                                                          didFinishProcessingPhoto photo: AVCapturePhoto,
                                                                          error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            imageClosure?(nil, error)
            return
        }
        
        if let image = UIImage(data: imageData) {
            imageClosure?(image, nil)
        }
    }
}
