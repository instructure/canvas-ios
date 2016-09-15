//
//  CreateAccountViewController.swift
//  Parent
//
//  Created by Brandon Pluim on 11/17/15.
//  Copyright © 2015 Instructure Inc. All rights reserved.
//

import UIKit

import SoLazy

public class CreateAccountViewController: UIViewController {
    
    
    public typealias CreateAccountSuccessfulAction = (String) -> ()
    public typealias CreateAccountFailedAction = (NSError) -> ()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    private var baseURL: NSURL = NSURL()
    
    public var success : CreateAccountSuccessfulAction?
    public var failure : CreateAccountFailedAction?
    
    /*
@POST("/accounts/{account_id}/self_registration")
void createSelfRegistrationUser(@Path("account_id") long account_id, @Query("user[name]") String userName, @Query("pseudonym[unique_id]") String emailAddress, @Query("user[terms_of_use]") int acceptsTerms, @Body String body, Callback<User> callback);
*/
    
    /*
http://mobile-1.portal2.canvaslms.com:3000/api/v1/accounts/1/self_registration?user[name]=VinDiesel&pseudonym[unique_id]=brady%2Bdiesel%40instructure.com&user[terms_of_use]=true
*/

    // ---------------------------------------------
    // MARK: - Initializers
    // ---------------------------------------------
    private static let defaultStoryboardName = "CreateAccountViewController"
    public static func new(storyboardName: String = defaultStoryboardName, baseURL: NSURL, clientID: String) -> CreateAccountViewController {
        guard let controller = UIStoryboard(name: storyboardName, bundle: NSBundle(forClass: self)).instantiateInitialViewController() as? CreateAccountViewController else {
            fatalError("Initial ViewController is not of type CreateAccountViewController")
        }
        
        controller.baseURL = baseURL
        
        return controller
    }
    
    // ---------------------------------------------
    // MARK: - UIViewController Lifecycle
    // ---------------------------------------------
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        initBackButtonIfNeeded()
        nameTextField.becomeFirstResponder()
        nameTextField.addTarget(self, action: "validateInput:", forControlEvents: .EditingChanged)
        emailTextField.addTarget(self, action: "validateInput:", forControlEvents: .EditingChanged)
        
        submitButton.enabled = false
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func validateInput(textfield: UITextField) {
        guard let user = nameTextField.text, email = emailTextField.text else {
            return
        }
        
        submitButton.enabled = !user.isEmpty && email.isValidEmail()
    }
    
    // ---------------------------------------------
    // MARK: - IBActions
    // ---------------------------------------------
    @IBAction func createUserButtonPressed(sender: UIButton) {
        guard let username = nameTextField.text, email = emailTextField.text else {
            return
        }
        
        guard let url = self.createUserURL(username, email: email) else {
            return
        }
        
        let request = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config, delegate: nil, delegateQueue: nil)
        session.dataTaskWithRequest(request) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue(), {
                
            })
            }.resume()
    }
    
    func createUserURL(username: String, email: String) -> NSURL? {
        guard let escapedUser = username.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
            escapedEmail = email.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) else {
                return nil
        }
        
        let urlComponents = NSURLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = "/api/v1/accounts/1/self_registration"
        urlComponents.queryItems = [
            NSURLQueryItem(name: "user[name]", value: escapedUser),
            NSURLQueryItem(name: "pseudonym[unique_id]", value: escapedEmail),
            NSURLQueryItem(name: "user[terms_of_use]", value: "1")
        ]
        
        return urlComponents.URL
    }
}