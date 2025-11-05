//
//  ScanViewController.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 8/8/25.
//

import UIKit
import AVFoundation // Required for AVCaptureDevice to check camera authorization
import Photos // Required for PHPhotoLibrary to check photo library authorization

class ScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var uploadFromGalleryButton: UIButton!
    @IBOutlet weak var cameraIconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupCameraIconImageView()
        setupButtons()
    }
    
    // MARK: - UI Setup Methods
    private func setupCameraIconImageView() {
        cameraIconImageView.layer.cornerRadius = cameraIconImageView.frame.size.width / 2
        cameraIconImageView.clipsToBounds = true
        cameraIconImageView.backgroundColor = UIColor.systemBlue
        cameraIconImageView.layer.borderWidth = 1.0
        cameraIconImageView.layer.borderColor = UIColor.white.cgColor
        cameraIconImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cameraIconTapped))
        cameraIconImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupButtons() {
        takePhotoButton.layer.cornerRadius = 10
        takePhotoButton.backgroundColor = .systemBlue
        takePhotoButton.setTitleColor(.white, for: .normal)
        takePhotoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        
        uploadFromGalleryButton.layer.cornerRadius = 10
        uploadFromGalleryButton.layer.borderWidth = 1.0
        uploadFromGalleryButton.layer.borderColor = UIColor.systemGray.cgColor
        uploadFromGalleryButton.backgroundColor = .clear
        uploadFromGalleryButton.setTitleColor(.systemBlue, for: .normal)
        uploadFromGalleryButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    
    //MARK: Actions - These are the entry points
    @objc func cameraIconTapped() {
        print("Camera icon tapped! Initiating camera access check.")
        requestCameraAccessAndOpenCamera() // Call the proactive permission function
    }
    
    @IBAction func takePhotoTapped(_ sender: Any) {
        print("Take photo button tapped! Initiating camera access check.")
        requestCameraAccessAndOpenCamera() // Call the proactive permission function
    }
    
    @IBAction func uploadPhotoTapped(_ sender: Any) {
        print("Upload photo button tapped! Initiating photo library access check.")
        requestPhotoLibraryAccessAndOpenLibrary() // Call the proactive permission function
    }
    
    // MARK: - Camera Access Logic (Proactive)
    func requestCameraAccessAndOpenCamera() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showAlert(title: "Camera Not Available", message: "This device does not have a camera.")
            return
        }
        
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
           
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
               
                DispatchQueue.main.async {
                    if granted {
                        print("Camera permission granted (after request). Opening camera.")
                        self?.openImagePicker(sourceType: .camera)
                    } else {
                        print("Camera permission denied (after request).")
                        self?.showAlertForPermissionDenied(for: "Camera")
                    }
                }
            }
        case .authorized:
            print("Camera permission already authorized. Opening camera.")
            openImagePicker(sourceType: .camera)
        case .denied:
            print("Camera permission denied. User needs to enable in settings.")
            showAlertForPermissionDenied(for: "Camera")
        case .restricted:
            print("Camera access restricted.")
            showAlert(title: "Camera Access Restricted", message: "Camera access is restricted on this device, possibly due to parental controls.")
        @unknown default:
            fatalError("Unknown camera authorization status")
        }
    }
    
    // MARK: - Photo Library Access Logic
    func requestPhotoLibraryAccessAndOpenLibrary() {
        // First, check if the photo library is available
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            showAlert(title: "Photo Library Not Available", message: "This device does not have a photo library.")
            return
        }
        
       
        let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoLibraryAuthorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
             
                DispatchQueue.main.async {
                    if status == .authorized {
                        print("Photo Library permission granted. Opening library.")
                        self?.openImagePicker(sourceType: .photoLibrary)
                    } else {
                        print("Photo Library permission denied (after request).")
                        self?.showAlertForPermissionDenied(for: "Photo Library")
                    }
                }
            }
        case .authorized:
            print("Photo Library permission already authorized. Opening library.")
            openImagePicker(sourceType: .photoLibrary)
        case .denied:
            print("Photo Library permission denied. User needs to enable in settings.")
            showAlertForPermissionDenied(for: "Photo Library")
        case .restricted:
            print("Photo Library access restricted.")
            showAlert(title: "Photo Library Access Restricted", message: "Photo library access is restricted on this device, possibly due to parental controls.")
        @unknown default:
            fatalError("Unknown photo library authorization status")
        }
    }

    // MARK: - Generic Image Picker Presentation Function (NEW/Consolidated)
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            if let pickedImage = info[.originalImage] as? UIImage {
                print("Image picked successfully! Image size: \(pickedImage.size)")
                //TODO: When user picked the image from the gallery we can pass that to our OCR system
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("Image picking canceled.")
    }
    
    // MARK: - Helper Functions for Alerts
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlertForPermissionDenied(for permissionType: String) {
        let alert = UIAlertController(
            title: "\(permissionType) Access Denied",
            message: "Please enable \(permissionType) access in your iPhone Settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        present(alert, animated: true)
    }
}
