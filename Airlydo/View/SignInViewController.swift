//
//  SignInViewController.swift
//  Airlydo
//
//  Created by yoshiki-t on 2018/06/28.
//  Copyright © 2018年 yoshiki-t. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase


class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var statusText: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        self.statusText.text = "initializing..."
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if user != nil {
                let ContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
                self.present(ContainerViewController, animated: true, completion: nil)
                
            } else {
                if GIDSignIn.sharedInstance().hasAuthInKeychain() {
                    GIDSignIn.sharedInstance().signInSilently()
                    
                } else {
                    self.statusText.text = "PLease Login"
                }
            }
            
        }
        
    }
    
}

// Google Sign-in
extension SignInViewController : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            print(user.profile.email)
        }
        
        // Get Firebase Credential
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // SignIn to Firebase
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if error != nil {
                // ...
                return
            }
            
            let ContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContainerViewController") as! ContainerViewController
            self.present(ContainerViewController, animated: true, completion: nil)
        }
    
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
}
