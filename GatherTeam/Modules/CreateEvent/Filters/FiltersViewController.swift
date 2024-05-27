//
//  FiltersViewController.swift
//  GatherTeam
//
//  Created by Nikita on 15.01.2024.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var starsOutlets: [UIButton]!
    
    var viewModel: FiltersViewModelType!
    var selectedType: EventTypes = .football
    private var minimumStars = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = CustomFlowLayout()
    }
    
    @IBAction func starPressed(_ sender: UIButton) {
        minimumStars = sender.tag
        
        for index in 0..<starsOutlets.count {
            starsOutlets[index].tintColor = index < sender.tag ? .systemYellow : .systemGray
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyPressed(_ sender: UIButton) {
        viewModel.applyFilters(with: FilterModel(eventType: selectedType, playersRate: minimumStars, playersAmount: 0))
        self.navigationController?.popViewController(animated: true)
    }
}

extension FiltersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EventTypes.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as! EventCollectionViewCell
        
        cell.view.layer.cornerRadius = 16
        cell.view.layer.borderWidth = 1
        cell.view.layer.borderColor = EventTypes.allCases[indexPath.item] == selectedType ? UIColor.black.cgColor : UIColor.black.withAlphaComponent(0.12).cgColor
        
        cell.typeImageView.image = EventTypes.allCases[indexPath.item].image
        cell.typeLabel.text = EventTypes.allCases[indexPath.item].title
        
        return cell
    }
}

extension FiltersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedType = EventTypes.allCases[indexPath.item]
        collectionView.reloadData()
    }
}

class CustomFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()

        scrollDirection = .horizontal
        minimumLineSpacing = 10  // Adjust this value as needed
        minimumInteritemSpacing = 10  // Adjust this value as needed
        itemSize = CGSize(width: 128, height: 128)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // You can leave this empty or implement it based on your needs
    }

    // You can override other methods if needed, such as preparing the layout or calculating the content size.

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        return attributes?.map { $0.copy() as! UICollectionViewLayoutAttributes }
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
