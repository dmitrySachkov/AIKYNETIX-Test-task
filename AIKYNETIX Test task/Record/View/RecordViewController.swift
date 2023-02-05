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

class RecordViewController: UIViewController {

    private var cancelable = Set<AnyCancellable>()
    private var viewModel = RecordVideoViewModel()
    @Published private var isButtonPressed = false
    
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
                            self.viewModel.saveToLocal(tempFile: url)
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
        isButtonPressed.toggle()
    }
}
