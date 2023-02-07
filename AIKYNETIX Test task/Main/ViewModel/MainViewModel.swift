//
//  MainViewModel.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 03.02.2023.
//

import Foundation
import Combine
import CoreData
import Photos

struct VideoSaved {
    var name: String
}


class MainViewModel: ObservableObject {
    
    @Published var videos: Array<VideoModel>?
    @Published var secondVideos: Array<VideoSaved>?
    private var cancelable = Set<AnyCancellable>()
    private var currentVideo: PHAsset?
    
    private var persistentContainer: NSPersistentContainer = {
          let container = NSPersistentContainer(name: "AIKYNETIX_Test_task")
          container.loadPersistentStores(completionHandler: { (storeDescription, error) in
              if let error = error as NSError? {
                  fatalError("Unresolved error \(error), \(error.userInfo)")
              }
          })
          return container
      }()
    
    
    init() {
        fetchCoreData()
        fetchSecondCoreData()
    }
    
    func fetchCoreData() {
        self.videos = []
        let fetch = NSFetchRequest<Video>(entityName: "Video")
        CoreDataPublisher(request: fetch, context: persistentContainer.viewContext)
            .map { $0.map { VideoModel(name: $0.name, data: $0.data, date: $0.date) } }
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] videos in
                guard let self = self else { return }
                self.videos?.append(contentsOf: videos)
            })
            .store(in: &cancelable)
    }
    
    func fetchSecondCoreData() {
        self.secondVideos = []
        let fetch = NSFetchRequest<Videos>(entityName: "Videos")
        CoreDataPublisher(request: fetch, context: persistentContainer.viewContext)
            .map { $0.map { VideoSaved(name: $0.name ?? "") } }
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] videos in
                guard let self = self else { return }
                self.secondVideos?.append(contentsOf: videos)
            })
            .store(in: &cancelable)
    }
}
