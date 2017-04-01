//
//  ViewController.swift
//  FirebaseSocialLogin
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import TwitterKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup sns buttons
        let FBButton = setupFacebookButton()
        let customFBButton = setupCustomFacebookButton()
        let googleButton = setupGoogleButton()
        let customGoogleButton = setupCustomGoogleButton()
        let twitterButton = setupTwitterButton()

        // layout buttons
        let buttons = ["FBButton": FBButton,
                       "customFBButton": customFBButton,
                       "googleButton": googleButton,
                       "customGoogleButton": customGoogleButton,
                       "twitterButton": twitterButton
        ]
        buttons.forEach { $1.translatesAutoresizingMaskIntoConstraints = false }
        self.view.addConstraints(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[FBButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[customFBButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[googleButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[customGoogleButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[twitterButton]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons) +
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-50-[FBButton]-8-[customFBButton]-50-[googleButton]-8-[customGoogleButton]-50-[twitterButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: buttons)
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
        customFBButton.layer.cornerRadius = 3
        view.addSubview(customFBButton)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        return customFBButton
    }
    
    func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { ( result, err ) in
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
    
    func showEmailAddress() {
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with Facbook: ", error ?? "")
                return
            }
            print("Successfully logged in with Facebook:", user ?? "")
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            print(result ?? "")
        }
    }
    
    // Google sign in button
    fileprivate func setupGoogleButton() -> GIDSignInButton {
        let googleButton = GIDSignInButton()
        view.addSubview(googleButton)
        return googleButton
    }
    
    // custom Google sign in button
    fileprivate func setupCustomGoogleButton() -> UIButton {
        let customGoogleButton = UIButton()
        customGoogleButton.translatesAutoresizingMaskIntoConstraints = false
        customGoogleButton.setTitle("Google Sign in", for: .normal)
        customGoogleButton.setTitleColor(.darkGray, for: .normal)
        customGoogleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customGoogleButton.backgroundColor = .clear
        customGoogleButton.layer.cornerRadius = 3
        customGoogleButton.layer.borderWidth = 1
        customGoogleButton.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(customGoogleButton)
        customGoogleButton.addTarget(self, action: #selector(handleCustomGoogleSignIn), for: .touchUpInside)
        return customGoogleButton
    }
    
    func handleCustomGoogleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    // Twitter sign in button
    fileprivate func setupTwitterButton() -> TWTRLogInButton {

        let twitterButton = TWTRLogInButton { (session, error) in
            if let err = error {
                print("Failed to login via Twitter: ", err)
                return
            }
            
            // login with Firebase
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                
                if let err = error {
                    print("Failed to login to Firebase with Twitter: ", err)
                    return
                }
                print("Successfully created a Firebase-Twitter user: ", user?.uid ?? "")
            })
        }
        view.addSubview(twitterButton)
        return twitterButton
    }
}
