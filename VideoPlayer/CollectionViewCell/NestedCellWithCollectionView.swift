//
//  NestedCellWithCollectionView.swift
//  VideoPlayer
//
//  Created by Mandeep Singh on 08/07/19.
//  Copyright © 2019 Mandeep Singh. All rights reserved.
//

import UIKit

class NestedCellWithCollectionView: UICollectionViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var cellClosure: ((_ status: AnyObject) -> ())?
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>(_ dataSourceDelegate: D, forRow row: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.register(UINib(nibName: "CollectionCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CollectionCell")
    }
    
    deinit {
        print("deinit NestedCellWithCollectionView")
    }

}

