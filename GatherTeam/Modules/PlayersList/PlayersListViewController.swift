//
//  PlayersListViewController.swift
//  GatherTeam
//
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import MapKit

class PlayersListViewController: UIViewController {
    var viewModel: PlayersListViewModelType!
    private var ref: DatabaseReference!
    private var selectedUserIds: [String] = []
    private var users: [UserModel] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        getUsersIds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getUsersIds() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ref.child("events").child(viewModel.eventModel.id).child("users").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let self else { return }

            self.selectedUserIds = snapshot.value as? [String] ?? []
            self.selectedUserIds.removeAll(where: { $0 == uid })
            getUsersModels()
        })
    }
    
    func getUsersModels() {
        for userId in selectedUserIds {
            ref.child("users").child(userId).getData { [weak self] error, snapshot in
                guard let self else { return }
                
                for user in snapshot?.value as? [String: [String:Any]] ?? [:] {
                    users.append(UserModel(
                        username: user.value["username"] as? String ?? "",
                        profileImage: user.value["profileImage"] as? String ?? "",
                        uid: userId
                    ))
                }
                getUsersModelsRatings()
                tableView.reloadData()
            }
        }
    }
    
    func getUsersModelsRatings() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ref.child("events").child(viewModel.eventModel.id).child("usersRatings").queryOrdered(byChild: "parentId").queryEqual(toValue: uid).observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let self else { return }
            
            for rating in snapshot.value as? [String: [String:Any]] ?? [:] {
                let childId = rating.value["childId"] as? String ?? ""
                let rating = rating.value["rating"] as? Int ?? 0
                if let index = users.firstIndex(where: { $0.uid == childId }) {
                    users[index].rating = rating
                }
                
            }
            
            tableView.reloadData()
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func updateUserRating(with ratingAmount: Int, to childPlayerId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let rating = [
            "parentId": uid,
            "childId": childPlayerId,
            "rating": ratingAmount
        ] as [String : Any]
        
        ref.child("events").child(viewModel.eventModel.id).child("usersRatings").childByAutoId().updateChildValues(rating)
        
        ref.child("users").child(uid).child("data").child("globalRating").getData { [weak self] error, snapshot in
            guard let self, var ratings = snapshot?.value as? [Int] else {
                self?.ref.child("users").child(uid).child("data").child("globalRating").setValue([ratingAmount])
                return
            }
            
            ratings.append(ratingAmount)
            
            ref.child("users").child(uid).child("data").child("globalRating").setValue(ratings)
        }
    }
}

extension PlayersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { users.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell", for: indexPath) as! PlayerTableViewCell
        cell.usernameLabel.text = users[indexPath.item].username
        getData(from: URL(string: users[indexPath.item].profileImage)!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() { [weak self] in
                cell.playerImageView.image = UIImage(data: data)
            }
        }
        cell.playerImageView.layer.cornerRadius = cell.playerImageView.frame.height / 2
        if users[indexPath.item].rating > 0 {
            cell.isUserInteractionEnabled = false
            for index in 0..<5 {
                cell.starsLabel[index].tintColor = index < users[indexPath.item].rating ? .systemYellow : .systemGray
            }
        }
        cell.starPressedHandler = { [weak self] tag in
            guard let self else { return }
            
            for index in 0..<5 {
                cell.starsLabel[index].tintColor = index < tag ? .systemYellow : .systemGray
            }
            updateUserRating(with: tag, to: users[indexPath.item].uid)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 86 }
}

extension PlayersListViewController: UITableViewDelegate {
    
}
