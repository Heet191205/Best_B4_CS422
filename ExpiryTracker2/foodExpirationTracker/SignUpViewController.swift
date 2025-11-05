//
//  SignUpViewController.swift
//  foodExpirationTracker
//
//  Created by Mahir Patel on 8/7/25.
//

import UIKit
import CoreData

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var emailAddressField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBAction func SignUpButton(_ sender: Any) {
        
        guard let fullName = fullNameTextField.text, fullNameTextField.text != "" else {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter your full name.", preferredStyle: .alert)
                       alert.addAction(UIAlertAction(title: "OK", style: .default))
                       self.present(alert, animated: true)
                       return
        }

        
        guard let email = emailAddressField.text, emailAddressField.text != "" else {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter your email address.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                        return
            
        }

        
        
        guard let pass = passwordField.text, passwordField.text != "" else {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter a password.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                                    return
        }

        
        guard let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
                    let alert = UIAlertController(title: "Missing Information", message: "Please confirm your password.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: email) {
                   
                    let alert = UIAlertController(title: "Invalid Email Format", message: "Please enter a valid email address (e.g., example@domain.com).", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
        print("Email format is valid. Proceeding with other validations...")
                
        
                var passwordStrengthMessage = ""

                // Check minimum length
                if pass.count < 8 {
                    passwordStrengthMessage += "• At least 8 characters long.\n"
                }
                // Check for uppercase letter
                let uppercaseRegex = ".*[A-Z].*"
                if !NSPredicate(format: "SELF MATCHES %@", uppercaseRegex).evaluate(with: pass) {
                    passwordStrengthMessage += "• At least one uppercase letter.\n"
                }
                // Check for lowercase letter
                let lowercaseRegex = ".*[a-z].*"
                if !NSPredicate(format: "SELF MATCHES %@", lowercaseRegex).evaluate(with: pass) {
                    passwordStrengthMessage += "• At least one lowercase letter.\n"
                }
                // Check for digit
                let digitRegex = ".*[0-9].*"
                if !NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: pass) {
                    passwordStrengthMessage += "• At least one digit.\n"
                }
                // Check for special character
                let specialCharacterRegex = ".*[!@#$%^&*()\\-_=+/?.,;:'\"`~].*" // Escaped special characters
                if !NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex).evaluate(with: pass) {
                    passwordStrengthMessage += "• At least one special character (e.g., !@#$%^&*).\n"
                }

                if !passwordStrengthMessage.isEmpty {
                    let alert = UIAlertController(title: "Weak Password", message: "Your password must meet the following criteria:\n\(passwordStrengthMessage)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                print("Password strength is valid.")
        
            if pass != confirmPassword {
            let alert = UIAlertController(title: "Passwords Do Not Match", message: "Please ensure that your passwords match.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return 
        }
        
        
        //Core data Saving logic
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //check if user already exists or not
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest() // Use to generate the user class
        fetchRequest.predicate = NSPredicate(format: "emailAddress == %@", email)
        
        do{
            let existingUsers = try managedContext.fetch(fetchRequest)
            if !existingUsers.isEmpty{
                let alert = UIAlertController(title: "Account Exists", message: "An account with this email address already exists. Please log in or use a different email.", preferredStyle: .alert)
                           alert.addAction(UIAlertAction(title: "OK", style: .default))
                           self.present(alert, animated: true)
                           return
            }
            
            
        }catch{
            print("Error checking for existing user: \(error)")
                        let alert = UIAlertController(title: "Error", message: "Could not check for existing account. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                        return
        }
        
        //Create and save the new user to core data model
        let newUser = User(context: managedContext)
        
        //Set the values
        newUser.fullName = fullName
        newUser.emailAddress = email
        newUser.password = pass
        
        do{
                try managedContext.save()
                      print("User created successfully!")
                      let alert = UIAlertController(title: "Success!", message: "Your account has been created. You can now log in.", preferredStyle: .alert)
                      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                          self.dismiss(animated: true, completion: nil) // Dismisses the current sign-up view
                      }))
                      self.present(alert, animated: true)
        }catch {
            print("Could not save new user. \(error)")
                        let alert = UIAlertController(title: "Sign Up Failed", message: "There was an error creating your account. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
        }
        
        print("Congratualions You are successfully signed up!")
        
    }
}
