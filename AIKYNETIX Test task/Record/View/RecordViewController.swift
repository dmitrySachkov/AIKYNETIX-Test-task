//
//  RecordViewController.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 03.02.2023.
//

import UIKit
import AVFoundation
import Combine
import Photos
import FirebaseCrashlytics

class RecordViewController: UIViewController {

    private var cancelable = Set<AnyCancellable>()
    private var viewModel = RecordVideoViewModel()
    @Published private var isButtonPressed = false
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 5.0
    var lastZoomFactor: CGFloat = 1.0
    var newCamera: AVCaptureDevice?
    
    var onUpdate: (() -> Void)?
    
    private(set) lazy var shutButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(shutButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        binding()
        
        newCamera = cameraWithPosition(position: .back)
        //Add Pinch Gesture on CameraView.
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(pinch(_:)))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.cameraService.previewLayer.frame = view.bounds
    }
    
    //MARK: - Setup UI element
    private func setupUI() {
        view.layer.addSublayer(viewModel.cameraService.previewLayer)
        view.addSubview(shutButton)
        
        shutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
            make.width.height.equalTo(75)
        }
        shutButton.layoutIfNeeded()
        shutButton.layer.cornerRadius = shutButton.frame.width / 2
    }
    
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
          let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
          for device in discoverySession.devices {
                if device.position == position {
                    return device
                }
           }
           return nil
      }
    
    //MARK: - Set Binding
    private func binding() {
        $isButtonPressed
            .sink { [weak self] isPressed in
                guard let self = self else { return }
                if isPressed {
                    self.shutButton.backgroundColor = .red
                    self.viewModel.cameraService.recordVideo { url, error in
                        guard let url = url else { return }
                        let asset: AVAsset = AVAsset(url: url)
                        var duration: Float = Float(CMTimeGetSeconds(asset.duration))
                        if duration - 300 > 300 {
                            self.viewModel.cropVideo(sourceURL1: url, statTime: duration - 300, endTime: duration)
                        } else {
                            self.viewModel.saveVideoToLibrary(videoURL: url)
                        }
                        self.onUpdate?()
                    }
                } else {
                    self.shutButton.backgroundColor = .black
                    self.viewModel.cameraService.stopRecording { error in
                    }
                }
            }
            .store(in: &cancelable)
        
        viewModel.$isSaved
            .sink { [weak self] isSaved in
                guard let self = self else { return }
                if isSaved {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            .store(in: &cancelable)
    }
    
    //MARK: - Button pressed
    @objc private func shutButtonPressed(_ sender: UIButton) {
        let numbers = [0]
        let _ = numbers[1]
        isButtonPressed.toggle()
    }
    
    @objc func pinch(_ pinch: UIPinchGestureRecognizer) {
        guard let device = newCamera else { return }
        
        // Return zoom value between the minimum and maximum zoom values
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
}
