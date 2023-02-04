//
//  MainViewModel.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 03.02.2023.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    
    @Published var videos: Array<VideoModel> = []
    
    init() {
        setDummyData()
    }
    
    private func setDummyData() {
        let dummyData: Array<VideoModel> = [.init(name: "First", date: "03.02.2023"),
                                            .init(name: "Second", date: "02.02.2023"),
                                            .init(name: "Third", date: "01.02.2023"),
                                            .init(name: "Fourth", date: "31.01.2023")]
        self.videos = dummyData
    }
}
