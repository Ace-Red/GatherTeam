//
//  ProfileViewController.swift
//  GatherTeam
//
//  Created by Nikita on 07.12.2023.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import AuthenticationServices
import CryptoKit
import FirebaseDatabase

class ProfileViewController: UIViewController {

    @IBOutlet weak var placeholderView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteAccountOutlet: UIButton!
    @IBOutlet weak var logOutOutlet: UIButton!
    @IBOutlet weak var selectRoleView: UIView!
    @IBOutlet weak var adminButtonOutlet: UIButton!
    @IBOutlet weak var userButtonOutlet: UIButton!
    
    private var currentNonce: String?
    private var ref: DatabaseReference!
    private var isAdmin = false
    
    var viewModel: ProfileViewModelType!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupProfile()
    }
    
    private func setupProfile() {
        if let uid = Auth.auth().currentUser?.uid {
            ref.child("users").child(uid).child("data").child("role").getData(completion: { [weak self] error, dataSnapshot in
                guard let self, let role = dataSnapshot?.value as? String else { return }
                
                self.isAdmin = role == "admin"
                tableView.reloadData()
            })
        }
        
        placeholderView.isHidden = Auth.auth().currentUser != nil
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        
        if let auth = Auth.auth().currentUser {
            usernameLabel.text = auth.displayName ?? ""
            
            ref.child("users").child(auth.uid).child("data").child("globalRating").getData { [weak self] error, snapshot in
                guard let self, let ratings = snapshot?.value as? [Int] else { return }
                
                let totalRating = ratings.reduce(0, +)
                usernameLabel.text = "\(auth.displayName ?? "") \n Current rating: \(totalRating/ratings.count)⭐"
            }
            
            if let url = auth.photoURL {
                getData(from: url) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.async() { [weak self] in
                        self?.profileImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    private func setupViews() {
        logOutOutlet.layer.borderWidth = 1
        logOutOutlet.layer.borderColor = UIColor.red.cgColor
        logOutOutlet.layer.cornerRadius = 16
        
        deleteAccountOutlet.layer.borderWidth = 1
        deleteAccountOutlet.layer.borderColor = UIColor.red.cgColor
        deleteAccountOutlet.layer.cornerRadius = 16
        
        adminButtonOutlet.layer.borderWidth = 1
        adminButtonOutlet.layer.borderColor = UIColor.green.cgColor
        adminButtonOutlet.backgroundColor = UIColor.green.withAlphaComponent(0.12)
        adminButtonOutlet.layer.cornerRadius = 16
        
        userButtonOutlet.layer.borderWidth = 1
        userButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
        userButtonOutlet.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        userButtonOutlet.layer.cornerRadius = 16
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    @IBAction func signInWithGooglePressed(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else { return }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                guard let self else { return }
                
                userSignedIn()
            }
        }
    }
    
    @IBAction func signInWithApplePressed(_ sender: UIButton) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }
    
    private func userSignedIn() {
        setupProfile()
        placeholderView.isHidden = true
        
        guard 
            let uid = Auth.auth().currentUser?.uid,
            let username = Auth.auth().currentUser?.displayName,
            let profileImage = Auth.auth().currentUser?.photoURL?.absoluteString
        else { return }
        
        ref.child("users").child(uid).child("data").updateChildValues(["username":username])
        ref.child("users").child(uid).child("data").updateChildValues(["profileImage":profileImage])
        
        ref.child("users/\(uid)/data/role").getData { error, snapshot in
            if let data = snapshot?.value as? String {
                print(data)
            } else {
                self.selectRoleView.isHidden = false
            }
        }
    }
    
    @IBAction func deleteAccountPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Alert", message: "Do you really want to delete account", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete account", style: .destructive, handler: { action in
            switch action.style {
            case .cancel:
                print("cancel")
                
            case .destructive:
                self.deleteAccont()
                
            case .default:
                print("default")
            }
        }))
        
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    private func deleteAccont() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ref.child("users/\(uid)").removeValue { [weak self] _, some in
            guard let self else { return }
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                return
            }
            
            placeholderView.isHidden = false
        }
    }
    
    @IBAction func adminPressed(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        ref.child("users").child(uid).child("data").updateChildValues(["role":"admin"])
        isAdmin = true
        selectRoleView.isHidden = true
        setupProfile()
    }
    
    @IBAction func userPressed(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        ref.child("users").child(uid).child("data").updateChildValues(["role":"user"])
        isAdmin = false
        selectRoleView.isHidden = true
        setupProfile()
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            return
        }
        
        placeholderView.isHidden = false
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isAdmin ? Settings.allCases.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        let model = Settings.allCases[indexPath.item]
        
        cell.nameLabel.text = model.title
        cell.imageBackgroundView.layer.cornerRadius = 8
        cell.eventImageView.image = UIImage(named: model.icon)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Settings.allCases[indexPath.item] {
        case .createEvent:
            viewModel.goToEnterEventName()
        case .myCreatedEvents:
            viewModel.goToEventsList()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension ProfileViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else { return }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            
            Auth.auth().signIn(with: credential) { [weak self] _, error in
                guard let self = self else { return }
                
                if let _ = error {
                    return
                }
                
                userSignedIn()
            }
        }
    }
    
    private func randomNonceString() -> String {
        let length: Int = 32
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                _ = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
