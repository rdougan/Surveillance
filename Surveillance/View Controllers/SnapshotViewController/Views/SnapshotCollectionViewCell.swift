//
//  SnapshotCollectionViewCell.swift
//  Surveillance
//
//  Created by Robert Dougan on 01/11/2018.
//  Copyright © 2018 Robert Dougan. All rights reserved.
//

import UIKit

class SnapshotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    fileprivate var timer: Timer?
    
    func startTimer(with url: URL) {
        if let timer = self.timer {
            timer.invalidate()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer: Timer) in
            self.downloadImage(with: url)
        })
        
        self.downloadImage(with: url)
    }
    
    func stopTimer() {
        if let timer = self.timer {
            timer.invalidate()
        }
    }
    
    fileprivate func downloadImage(with url: URL) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            
            DispatchQueue.main.async {
                guard let cgImage = UIImage(data: data!)?.cgImage else { return }
                let portraitImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
                
                self.imageView.image = portraitImage
            }
        }.resume()
    }
    
}
