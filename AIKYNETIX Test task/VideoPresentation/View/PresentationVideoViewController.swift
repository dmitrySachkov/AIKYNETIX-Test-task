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
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        player = AVPlayer(url: viewModel.video)
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
    
//    private func setPlayer(view: UIView) {
//        player = AVPlayer(url: viewModel.video)
//        let layer = AVPlayerLayer(player: player)
//        view.layer.addSublayer(layer)
//        layer.frame = view.bounds
//        layer.videoGravity = .resizeAspectFill
//        player?.volume = 0
//    }
    
    private func setButton() {
        if isPressed {
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player?.play()
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player?.pause()
        }
    }
    
    private func binding() {
        $isPressed
            .sink { [weak self] isPressed in
                guard let self = self else { return }
                self.setButton()
            }
            .store(in: &cancelable)
    }
    
    @objc private func buttonPressed(_ sender: UIButton) {
        isPressed.toggle()
    }
}
