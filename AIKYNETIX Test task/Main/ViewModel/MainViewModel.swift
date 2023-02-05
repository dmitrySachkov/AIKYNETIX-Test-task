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


class MainViewModel: ObservableObject {
    
    @Published var videos: Array<VideoModel>?
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
    
    func loadData(by name: String) -> URL {
        let fm = FileManager.default
        let docURL = try! fm.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let path = docURL.appendingPathComponent(name)
        
        print(URL(fileURLWithPath: path.absoluteString))
        return URL(fileURLWithPath: path.absoluteString)
    }
}
