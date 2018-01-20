//
//  ColorViewController.swift
//  OpenTerm
//
//  Created by Simon Andersson on 2018-01-13.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import UIKit

protocol ColorPickerViewControllerDelegate {
    
    func didSelectColor(color: UIColor)
    
}

class ColorPickerViewController: UIViewController {
    
    var colors = [UIColor]()
    
    var delegate: ColorPickerViewControllerDelegate?
    
    @IBOutlet weak var collectIonView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectIonView.dataSource = self
        collectIonView.delegate = self
        colors = [.defaultMainTintColor, .green, .panelBackgroundColor, .black, .darkGray, .gray, .lightGray, .white, .orange, .brown, .red, .magenta, .purple, .blue, .cyan]
        
    }
    
}

extension ColorPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectIonView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = colors[indexPath.row]
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.cornerRadius = 5
        
        return cell
        
    }
    
}

extension ColorPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.didSelectColor(color: colors[indexPath.row])
        navigationController?.popViewController(animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
    
}
