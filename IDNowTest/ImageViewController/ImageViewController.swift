//
//  ImageViewController.swift
//  IDNowTest
//
//  Created by Kristian Rusyn on 22/09/2024.
//

import Combine
import UIKit
import Photos

class ImageViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var viewModel: ImageViewModel
    
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: ImageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ImageViewController.self), bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupBindings()
        imageView.image = viewModel.image
        viewModel.fetchProduct()

        // Hide the activity indicator initially
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }

    private func setupNavigationBar() {
        let downloadButton = UIBarButtonItem(title: "Download",
                                             style: .plain,
                                             target: self,
                                             action: #selector(downloadImage))
        navigationItem.rightBarButtonItem = downloadButton
    }

    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
                self?.navigationItem.title = title
            }
            .store(in: &cancellables)

        viewModel.$description
            .receive(on: DispatchQueue.main)
            .sink { [weak self] description in
                self?.descriptionLabel.text = description
            }
            .store(in: &cancellables)

        viewModel.$price
            .receive(on: DispatchQueue.main)
            .sink { [weak self] price in
                self?.priceLabel.text = price
            }
            .store(in: &cancellables)

        viewModel.$image
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.imageView.image = image
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let message = errorMessage {
                    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
            .store(in: &cancellables)
    }

    @objc private func downloadImage() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    self?.saveImageToPhotoLibrary()
                case .denied, .restricted:
                    let alert = UIAlertController(title: "Access Denied",
                                                  message: "Please allow photo library access in Settings to save images.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                case .notDetermined:
                    break
                @unknown default:
                    let alert = UIAlertController(title: "Unknown Error",
                                                  message: "An unknown error occurred while accessing the photo library.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    private func saveImageToPhotoLibrary() {
        guard let image = viewModel.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        var alert: UIAlertController
        if let error = error {
            alert = UIAlertController(title: "Save Error",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            alert = UIAlertController(title: "Saved",
                                          message: "Image has been saved to your photos.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        present(alert, animated: true, completion: nil)
    }
}
