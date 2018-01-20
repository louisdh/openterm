//
//  ColorViewController.swift
//  OpenTerm
//
//  Created by Simon Andersson on 2018-01-13.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {
    
	lazy var colors: [UIColor] = {
		return [.defaultMainTintColor,
				.green,
				.panelBackgroundColor,
				.black,
				.darkGray,
				.gray,
				.lightGray,
				.white,
				.orange,
				.brown,
				.red,
				.magenta,
				.purple,
				.blue,
				.cyan]
	}()
    
	var didSelectCallback: ((UIColor) -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
		
    }

}

extension ColorPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 5
        
        return cell
    }
    
}

extension ColorPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let color = colors[indexPath.row]
		didSelectCallback?(color)

		navigationController?.popViewController(animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
		
    }
    
}
