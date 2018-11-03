//
//  SnapshotZoomCollectionViewCell.swift
//  Surveillance
//
//  Created by Robert Dougan on 02/11/2018.
//  Copyright © 2018 Robert Dougan. All rights reserved.
//

import UIKit

class SnapshotZoomCollectionViewCell: SnapshotCollectionViewCell {
    
    @IBOutlet var scrollView: UIScrollView!
    
    var doubleTapGesture: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 4
        
        self.doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(SnapshotZoomCollectionViewCell.onDoubleTap))
        self.doubleTapGesture.numberOfTapsRequired = 2
        self.addGestureRecognizer(self.doubleTapGesture)
    }
    
    override func startTimer(with url: URL) {
        super.startTimer(with: url)
        
        self.scrollView.setZoomScale(1, animated: false)
    }
    
    @objc func onDoubleTap(_ recognizer: UITapGestureRecognizer) {
        if self.scrollView.zoomScale == 1 {
            let center = recognizer.location(in: recognizer.view)
            self.scrollView.zoom(to: zoomRectForScale(scale: self.scrollView.maximumZoomScale, center: center), animated: true)
        }
        else {
            self.scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        
        let newCenter = scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
}

extension SnapshotZoomCollectionViewCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
