//
//  ViewController.swift
//  FirebaseSocialLogin
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // login buttons
        let FBButton = setupFacebookButton()
        let customFBButton = setupCustomFacebookButton()
        let googleButton = setupGoogleButton()
        
        // layout buttons
        let buttons = ["FBButton": FBButton,
                       "customFBButton": customFBButton,
                       "googleButton": googleButton]
        buttons.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[FBButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[customFBButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[googleButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[FBButton]-8-[customFBButton]-8-[googleButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons)
        )
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    // Facebook login button
    fileprivate func setupFacebookButton() -> FBSDKButton {
        let FBButton = FBSDKLoginButton()
        view.addSubview(FBButton)
        FBButton.delegate = self
        FBButton.readPermissions = ["email", "public_profile"]
        return FBButton
    }
    
    // custom Facebook login button
    fileprivate func setupCustomFacebookButton() -> UIButton {
        let customFBButton = UIButton()
        customFBButton.backgroundColor = UIColor(red: CGFloat(59 / 255.0), green: CGFloat(89 / 255.0), blue: CGFloat(152 / 255.0), alpha: 1.0)
        customFBButton.translatesAutoresizingMaskIntoConstraints = false
        customFBButton.setTitle("Facebook Login", for: .normal)
        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(customFBButton)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return customFBButton
    }
    
    // google sign in button
    fileprivate func setupGoogleButton() -> GIDSignInButton {
        let googleButton = GIDSignInButton()
        view.addSubview(googleButton)
        return googleButton
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
                print("Something went wrong with Facbook: ", error ?? "")
                
                return
            }
            print("Successfully logged in with Facebook:", user ?? "")
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

