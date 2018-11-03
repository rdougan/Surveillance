//
//  SnapshotViewController.swift
//  Surveillance
//
//  Created by Robert Dougan on 01/11/2018.
//  Copyright © 2018 Robert Dougan. All rights reserved.
//

import UIKit

class SnapshotViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var tripleTapGesture: UITapGestureRecognizer?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.contentInsetAdjustmentBehavior = .never
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(forName: NVR_NOTIFICATION_FETCHED_CAMERAS, object: nil, queue: nil) { (notification) in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        do {
            try NVR.shared.getCameras()
        } catch {
            self.openConfiguration()
        }
        
        self.tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(SnapshotViewController.onTripleTap))
        self.tripleTapGesture?.numberOfTouchesRequired = 2
        self.tripleTapGesture?.numberOfTapsRequired = 3
        self.view.addGestureRecognizer(self.tripleTapGesture!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.view.removeGestureRecognizer(self.tripleTapGesture!)
    }
    
    func openConfiguration() {
        if let nvc = self.storyboard?.instantiateViewController(withIdentifier: "Configuration") {
            self.present(nvc, animated: true, completion: {
                
            })
        }
    }
    
    @objc func onDoubleTap() {
        guard let indexPath = self.collectionView.indexPathsForVisibleItems.first else { return }
        if let snapshotCell = self.collectionView.cellForItem(at: indexPath) as? SnapshotCollectionViewCell {
            snapshotCell.imageView.contentMode = snapshotCell.imageView.contentMode == .scaleAspectFit ? .scaleAspectFill : .scaleAspectFit
        }
    }
    
    @objc func onTripleTap() {
        self.openConfiguration()
    }
    
}

extension SnapshotViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let snapshotCell = cell as? SnapshotCollectionViewCell {
            if let snapshotURL = NVR.shared.cameras?[indexPath.row].snapshotURL {
                snapshotCell.startTimer(with: snapshotURL)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let snapshotCell = cell as? SnapshotCollectionViewCell {
            if let _ = NVR.shared.cameras?[indexPath.row].snapshotURL {
                snapshotCell.stopTimer()
            }
        }
    }
    
}

extension SnapshotViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NVR.shared.cameras?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SnapshotZoomCell", for: indexPath)

        return cell
    }
    
}

extension SnapshotViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.bounds.size
    }
    
}

