//
//  ViewController.swift
//  IDNowTest
//
//  Created by Kristian Rusyn on 22/09/2024.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    private let cameraService = CameraServiceImpl()
    
    @IBOutlet weak var captureButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        try! cameraService.setupCameraStream(view: view)
    }

    @objc func capturePhoto() {
        captureButton.isEnabled = false
        cameraService.capturePhoto(imageClosure: { [weak self] image, error  in
            self?.captureButton.isEnabled = true
            if let error {
                let alert = UIAlertController(title: "Error",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                self?.present(alert, animated: true)
            } else if let image {
                self?.openImageViewController(image: image)
            }
            
        })
    }
    
    private func openImageViewController(image: UIImage) {
        let imageViewController = ImageViewController(viewModel: ImageViewModel(image: image))
        present(UINavigationController(rootViewController: imageViewController), animated: true)
    }
}
