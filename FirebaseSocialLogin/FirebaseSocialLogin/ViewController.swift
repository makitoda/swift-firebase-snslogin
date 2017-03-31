//
//  ViewController.swift
//  FirebaseSocialLogin
//

import UIKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Facebook login button
        let FBButton = FBSDKLoginButton()
        view.addSubview(FBButton)
        FBButton.delegate = self
        FBButton.readPermissions = ["email", "public_profile"]
        
        // custom Facebook login button
        let customFBButton = UIButton()
        customFBButton.backgroundColor = UIColor(red: CGFloat(59 / 255.0), green: CGFloat(89 / 255.0), blue: CGFloat(152 / 255.0), alpha: 1.0)
        customFBButton.translatesAutoresizingMaskIntoConstraints = false
        customFBButton.setTitle("Facebook Login", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(customFBButton)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        // layout buttons
        let buttons = ["FBButton": FBButton,
                       "customFBButton": customFBButton]
        buttons.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[FBButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[customFBButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[FBButton]-8-[customFBButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons)
        )
    }
    
    func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) {
            
            (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err!)
                return
            }
            
            self.showEmailAddress()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        showEmailAddress()
    }
    
    func  showEmailAddress() {
        
        let accessToken = FBSDKAccessToken.current()
        guard  let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                
                return
            }
            print("Successfully logged in with our user:", user ?? "")
        
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start {
            (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
        }
    }
}

