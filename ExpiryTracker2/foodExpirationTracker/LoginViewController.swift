//
//  loginViewController.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 7/30/25.
//

import UIKit
import CoreData

class loginViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        }

    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextFeild: UITextField!
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let manageContext = appDelegate.persistentContainer.viewContext
        
        
        guard let emailAddress = emailTextField.text, !emailAddress.isEmpty else {
            
            let alert = UIAlertController(title: "Missing Information", message: "Please enter your email.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
            print("Please enter your email address")
            return
        }
        
        //Password
        guard let password = passwordTextFeild.text, !password.isEmpty else {
            
            print("Please enter your password")
            let alert = UIAlertController(title: "Missing Information", message: "Please enter both email and password.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
            return
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: emailAddress){
            
            
            print("The email address you entered is not in valid format")
            let alert = UIAlertController(title: "Invalid Email", message: "The email address you entered is not in the valid format. Please try again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
            
            return
        }
        print("Email Validation succesfully")
        
       //core data fetch request for the particular user
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        
        fetchRequest.predicate = NSPredicate(format: "emailAddress == %@ AND password == %@", emailAddress, password)
        
        do {
                    let users = try manageContext.fetch(fetchRequest)
                    
                    if let user = users.first {
                        
                        print("Login Successfully! Welcome, \(user.fullName ?? user.emailAddress ?? "user")!")
                        if let userEmail = user.emailAddress {
                            UserDefaults.standard.set(userEmail, forKey: "loggedInUserEmail")
                            print("Logged in user email stored in UserDefaults: \(userEmail)")
                        }
                        self.performSegue(withIdentifier: "showMainApp", sender: self)
                        
                    } else {
                        
                        let alert = UIAlertController(title: "Login Failed", message: "Incorrect email or password. Please try again.", preferredStyle: .alert) // Consolidated message
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        
                        alert.addAction(UIAlertAction(title: "Sign Up", style: .default, handler: { [weak self] _ in
                            self?.performSegue(withIdentifier: "showSignUp", sender: self)
                        }))
                        
                        self.present(alert, animated: true)
                    }
        }catch let error as NSError{
            print("Error fetching data: \(error), \(error.userInfo)")
                        let alert = UIAlertController(title: "Error", message: "An error occurred during login. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
        }

        
    }

}
