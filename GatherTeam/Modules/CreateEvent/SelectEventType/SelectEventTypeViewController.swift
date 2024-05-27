//
//  SelectEventTypeViewController.swift
//  GatherTeam
//
//  Created by Nikita on 24.12.2023.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class SelectEventTypeViewController: UIViewController {
    
    var viewModel: SelectEventTypeViewModelType!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = TwoCellsPerRowFlowLayout()
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectEventTypeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EventTypes.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCell", for: indexPath) as! EventCollectionViewCell
        
        cell.view.layer.cornerRadius = 16
        cell.view.layer.borderWidth = 1
        cell.view.layer.borderColor = UIColor.black.withAlphaComponent(0.12).cgColor
        
        cell.typeImageView.image = EventTypes.allCases[indexPath.item].image
        cell.typeLabel.text = EventTypes.allCases[indexPath.item].title
        
        return cell
    }
}

extension SelectEventTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.goToSelectDates(EventTypes.allCases[indexPath.item])
    }
}

class TwoCellsPerRowFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        minimumInteritemSpacing = 16
        minimumLineSpacing = 16
        sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        scrollDirection = .vertical
    }
    
    override func prepare() {
        super.prepare()
        
        if let collectionView = collectionView {
            let availableWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing
            let itemWidth = (availableWidth / 2).rounded(.down)
            itemSize = CGSize(width: itemWidth, height: itemWidth) // Assuming square cells, adjust height as needed
        }
    }
}
