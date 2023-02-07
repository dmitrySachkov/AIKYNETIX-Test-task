//
//  PresentationViewModel.swift
//  AIKYNETIX Test task
//
//  Created by Dmitry Sachkov on 04.02.2023.
//

import Foundation
import Combine

class PresentationViewModel: ObservableObject {
    
    var video: String
    
    init(video: String) {
        self.video = video
    }
}
 
