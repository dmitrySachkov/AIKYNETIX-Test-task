//
//  ViewController.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 03.02.2023.
//

import UIKit
import SnapKit
import Combine
import AVKit
import AVFoundation

class MainViewController: UIViewController {
    
    private var cancelable = Set<AnyCancellable>()
    private var viewModel = MainViewModel()
    
    private(set) lazy var tableView: UITableView = {
       let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        setTableView()
        binding()
    }

    //MARK: - Setup NavigationBar
    private func setupNavigationBar() {
        navigationItem.title = "AIKYNETIX"
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "video.badge.plus"), style: .plain, target: self, action: #selector(addNewVideoPressed))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    //MARK: - Setup UI element
    private func setupUI() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    //MARK: - Set TableView
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(VideoTableViewCell.self, forCellReuseIdentifier: "videoTableViewCell")
    }
    
    //MARK: - Set Binding
    private func binding() {
        viewModel.$videos
            .sink { [weak self] videos in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            .store(in: &cancelable)
    }
    
    //MARK: - Set NavigationBar item action
    @objc private func addNewVideoPressed(_ sender: UIBarButtonItem) {
        let recordVC = RecordViewController()
        recordVC.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.viewModel.fetchCoreData()
            self.viewModel.fetchSecondCoreData()
        }
        navigationController?.pushViewController(recordVC, animated: true)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "videoTableViewCell", for: indexPath) as? VideoTableViewCell else { return UITableViewCell() }
        let video = viewModel.videos?[indexPath.row]
        cell.configureCell(by: video?.name ?? "", date: video?.date ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        guard let data = viewModel.videos?[indexPath.row]  else { return }
        print("???? - urlPath in main is \(data.name)")
        let presentationViewModel = PresentationViewModel(video: data.name ?? "")
        let presentationVC = PresentationVideoViewController(viewModel: presentationViewModel)
        navigationController?.pushViewController(presentationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
