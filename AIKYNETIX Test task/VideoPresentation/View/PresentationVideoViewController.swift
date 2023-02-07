//
//  ShowVideoViewController.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 04.02.2023.
//

import UIKit
import AVKit
import AVFoundation
import Combine


class PresentationVideoViewController: UIViewController {
    
    private var viewModel: PresentationViewModel
    private var cancelable = Set<AnyCancellable>()
    private var player: AVPlayer?
    @Published var isPressed = false
    
    private(set) lazy var playerView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        return view
    }()
    
    private(set) lazy var playPauseButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        return button
    }()
    
    init(viewModel: PresentationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(viewModel.video)
        setupUI()
        binding()
    }
    
    //MARK: - Setup UI Elements
    private func setupUI() {
        view.backgroundColor = .systemBackground
        let fm = FileManager.default
        guard let folderURL = URL.createFolder(folderName: "StoredVideos") else {
            print("Can't create url")
            return
        }
        let name = viewModel.video
        let permanentFileURL = folderURL.appendingPathComponent(name)
        player = AVPlayer(url: permanentFileURL)
        let layer = AVPlayerLayer(player: player)
        view.layer.addSublayer(layer)
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        player?.volume = 0
        
        view.addSubview(playPauseButton)
        
        playPauseButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
    }
    
    //MARK: - Setup button
    private func setButton() {
        if isPressed {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player?.play()
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player?.pause()
        }
    }
    
    //MARK: - binding data
    private func binding() {
        $isPressed
            .sink { [weak self] isPressed in
                guard let self = self else { return }
                self.setButton()
            }
            .store(in: &cancelable)
    }
    
    //MARK: - Handled button press
    @objc private func buttonPressed(_ sender: UIButton) {
        isPressed.toggle()
    }
}
