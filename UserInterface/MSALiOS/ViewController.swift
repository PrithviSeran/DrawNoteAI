//------------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation.
// All rights reserved.
//
// This code is licensed under the MIT License.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files(the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions :
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//------------------------------------------------------------------------------

import UIKit
import MSAL

/// 😃 A View Controller that will respond to the events of the Storyboard.
///
///



class ViewController: UIViewController, UITextFieldDelegate, URLSessionDelegate {
    
    // Update the below to your client ID you received in the portal. The below is for running the demo only
    let kClientID = ""
    let kGraphEndpoint = ""
    let kAuthority = ""
    let kRedirectUri = ""
    
    let kScopes: [String] = ["user.read", "Notes.Create", "Notes.ReadWrite", "Notes.ReadWrite.All"] //
    
    var accessToken = String()
    var why = "WHYY"
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?

    var loggingText: UITextView!
    var signOutButton: UIButton!
    var callGraphButton: UIButton!
    var usernameLabel: UILabel!
    var photoButton: UIButton!
    var signInTitleOne: UILabel!
    var signInTitleTwo: UILabel!
    
    var currentAccount: MSALAccount?
    
    var currentDeviceMode: MSALDeviceMode?
    
    var buttonToAccountMap = [UIButton: MSALAccount]()
    
    var userSections: [String] = []
    var sectionID: [String] = []
    
    override func present(_ viewControllerToPresent: UIViewController,
                            animated flag: Bool,
                            completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
      }


    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        
        do {
            try self.initMSAL()
        } catch let error {
            self.updateLogging(text: "Unable to create Application Context \(error)")
        }
        
        self.loadCurrentAccount()
        self.refreshDeviceMode()
        self.platformViewDidLoadSetup()
        self.updateLogging(text: "OVER HEAR")
        
        // Create a UIScrollView
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        
        // Create a UIStackView
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        // Add buttons to the stack view
        guard let applicationContext = self.applicationContext else { return }
        
        let accountEnumerationParameters = MSALAccountEnumerationParameters()
        accountEnumerationParameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.accountsFromDevice(for: accountEnumerationParameters) { (accounts, error) in
            
            if let error = error {
                self.updateLogging(text: "Couldn't retrieve accounts with error: \(error)")
                return
            }
            
            guard let accounts = accounts, !accounts.isEmpty else {
                self.updateLogging(text: "No accounts found in cache.")
                self.updateCurrentAccount(account: nil)
                self.photoButton.isEnabled = false
                self.accessToken = ""
                return
            }
            
            for account in accounts {
                let button = UIButton(type: .system)
                button.setTitle(account.username, for: .normal)
                button.backgroundColor = .systemBlue
                button.setTitleColor(.white, for: .normal)
                button.layer.cornerRadius = 10
                self.buttonToAccountMap[button] = account
                button.addTarget(self, action: #selector(self.loadAccount(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            }
            
        }
        
        
        // Set constraints for UIScrollView
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 300),
            scrollView.widthAnchor.constraint(equalToConstant: 400), // Correct way to set width
            scrollView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        
        // Set constraints for UIStackView
        NSLayoutConstraint.activate([
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20) // For horizontal scrolling
        ])
         
         
    }

    func platformViewDidLoadSetup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appCameToForeGround(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCurrentAccount()
    }

    @objc func appCameToForeGround(notification: Notification) {
        self.loadCurrentAccount()
    }
}


// MARK: Initialization

extension ViewController {
    
    /**
     
     Initialize a MSALPublicClientApplication with a given clientID and authority
     
     - clientId:            The clientID of your application, you should get this from the app portal.
     - redirectUri:         A redirect URI of your application, you should get this from the app portal.
     If nil, MSAL will create one by default. i.e./ msauth.<bundleID>://auth
     - authority:           A URL indicating a directory that MSAL can use to obtain tokens. In Azure AD
     it is of the form https://<instance/<tenant>, where <instance> is the
     directory host (e.g. https://login.microsoftonline.com) and <tenant> is a
     identifier within the directory itself (e.g. a domain associated to the
     tenant, such as contoso.onmicrosoft.com, or the GUID representing the
     TenantID property of the directory)
     - error                The error that occurred creating the application object, if any, if you're
     not interested in the specific error pass in nil.
     */
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            self.updateLogging(text: "Unable to create authority URL")
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID,
                                                                  redirectUri: kRedirectUri,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.initWebViewParams()
    }
    
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
    }
}

// MARK: Shared device


extension ViewController {
    
    @objc func getDeviceMode(_ sender: UIButton) {
        
        //present(ViewControllerPhoto(), animated: true)
        
        if #available(iOS 13.0, *) {
            self.applicationContext?.getDeviceInformation(with: nil, completionBlock: { (deviceInformation, error) in
                
                guard let deviceInfo = deviceInformation else {
                    self.updateLogging(text: "Device info not returned. Error: \(String(describing: error))")
                    return
                }
                
                let isSharedDevice = deviceInfo.deviceMode == .shared
                let modeString = isSharedDevice ? "shared" : "private"
                self.updateLogging(text: "Received device info. Device is in the \(modeString) mode.")
            })
        } else {
            self.updateLogging(text: "Running on older iOS. GetDeviceInformation API is unavailable.")
        }
    }
}


extension ViewController {
    
    //print("Outside")
    @objc func getPhotos(_ sender: UIButton) {
        //ViewControllerPhoto().modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
        //self.present(vc, animated: true, completion: nil)
        //present(ViewControllerPhoto(), animated: true, completion: nil)
        
    }
    
}


// MARK: Acquiring and using token

extension ViewController {
    
    /**
     This will invoke the authorization flow.
     */
    
    @objc func callGraphAPI(_ sender: UIButton) {
        
        self.loadCurrentAccount { (account) in
            
            guard let currentAccount = account else {
                
                // We check to see if we have a current logged in account.
                // If we don't, then we need to sign someone in.
                self.acquireTokenInteractively()
                //self.photoButton.isEnabled = false;
                self.photoButton.isEnabled = true;
                return
            }
            self.photoButton.isEnabled = true;
            self.acquireTokenSilently(currentAccount)
        }
    }
    
    func acquireTokenInteractively() {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }

        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                
                self.updateLogging(text: "Could not acquire token: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            
            let accountName = ""
            let containerName = ""
            let sasToken = ""

            // Define the image path and the blob name
            //let imagePath = "/Users/prithviseran/Downloads/unnamed.jpg"
            let blobName = "authtoken.txt"

            // Construct the Blob URL
            let blobUrlString = "https://\(accountName).blob.core.windows.net/\(containerName)/\(blobName)?\(sasToken)"
            guard let blobUrl = URL(string: blobUrlString) else {
                fatalError("Invalid URL.")
            }

            // Read the image data
            /*guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) else {
                fatalError("Could not read image data.")
            }*/

            // Create the request
            var request = URLRequest(url: blobUrl)
            request.httpMethod = "PUT"
            request.setValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type") // text/plain
            
            
            
            guard let dataToUpload = self.accessToken.data(using: .utf8) else {
                print("Failed to encode string to data")
                return
            }

            // Upload the image
            let uploadTask = URLSession.shared.uploadTask(with: request, from: dataToUpload) { data, response, error in
                if let error = error {
                    print("Upload failed with error: \(error)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        print(dataToUpload)
                    } else {
                        print("Upload failed with status code: \(httpResponse.statusCode)")
                        print(httpResponse)
                    }
                }
            }

            uploadTask.resume()
            
            self.updateLogging(text: "Access token is \(self.accessToken)")
            self.updateCurrentAccount(account: result.account)
            self.getContentWithToken()
        }
    }
    
    func testAgain(_ account : MSALAccount!, completion: @escaping (String?) -> Void) {
        
        DispatchQueue.global().async {
            guard let applicationContext = self.applicationContext else { return }
            
            let parameters = MSALSilentTokenParameters(scopes: self.kScopes, account: account)
            
            applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
                
                if let error = error {
                    
                    let nsError = error as NSError
                    
                    // interactionRequired means we need to ask the user to sign-in. This usually happens
                    // when the user's Refresh Token is expired or if the user has changed their password
                    // among other possible reasons.
                    
                    if (nsError.domain == MSALErrorDomain) {
                        
                        if (nsError.code == MSALError.interactionRequired.rawValue) {
                            
                            DispatchQueue.main.async {
                                self.acquireTokenInteractively()
                            }
                            return
                        }
                    }
                    
                    self.updateLogging(text: "Could not acquire token silently: \(error)")
                    return
                }
                
                guard let result = result else {
                    
                    self.updateLogging(text: "Could not acquire token: No result returned")
                    return
                }
                
                self.accessToken = result.accessToken
                completion(self.accessToken)
            }
        }
    }
    
    
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        /**
         
         Acquire a token for an existing account silently
         
         - forScopes:           Permissions you want included in the access token received
         in the result in the completionBlock. Not all scopes are
         guaranteed to be included in the access token returned.
         - account:             An account object that we retrieved from the application object before that the
         authentication flow will be locked down to.
         - completionBlock:     The completion block that will be called when the authentication
         flow completes, or encounters an error.
         */
        
        let parameters = MSALSilentTokenParameters(scopes: kScopes, account: account)
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.acquireTokenInteractively()
                        }
                        return
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)")
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned")
                return
            }
            
            self.accessToken = result.accessToken
            //ViewControllerPhoto().
            
            let accountName = ""
            let containerName = ""
            let sasToken = ""

            // Define the image path and the blob name
            //let imagePath = "/Users/prithviseran/Downloads/unnamed.jpg"
            let blobName = "authtoken.txt"

            // Construct the Blob URL
            let blobUrlString = "https://\(accountName).blob.core.windows.net/\(containerName)/\(blobName)?\(sasToken)"
            guard let blobUrl = URL(string: blobUrlString) else {
                fatalError("Invalid URL.")
            }

            // Read the image data
            /*guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: imagePath)) else {
                fatalError("Could not read image data.")
            }*/

            // Create the request
            var request = URLRequest(url: blobUrl)
            request.httpMethod = "PUT"
            request.setValue("BlockBlob", forHTTPHeaderField: "x-ms-blob-type")
            request.setValue("text/plain", forHTTPHeaderField: "Content-Type") // text/plain
            
            
            
            guard let dataToUpload = self.accessToken.data(using: .utf8) else {
                print("Failed to encode string to data")
                return
            }

            // Upload the image
            let uploadTask = URLSession.shared.uploadTask(with: request, from: dataToUpload) { data, response, error in
                if let error = error {
                    print("Upload failed with error: \(error)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 201 {
                        print(self.accessToken.data(using: .utf8))
                    } else {
                        print("Upload failed with status code: \(httpResponse.statusCode)")
                        print(httpResponse)
                    }
                }
            }

            uploadTask.resume()
            self.accessToken = result.accessToken
            self.why = result.accessToken
            self.updateLogging(text: "Refreshed Access token is \(self.accessToken)")
            self.updateSignOutButton(enabled: false)
            self.getContentWithToken()
            //completion(self.accessToken)
            //let photo = ViewControllerPhoto()
            //photo.currentAccount = self.currentAccount
            
            //self.present(photo, animated: true)
        }
    }
    
    func getGraphEndpoint() -> String {
        return kGraphEndpoint.hasSuffix("/") ? (kGraphEndpoint + "v1.0/me/") : (kGraphEndpoint + "/v1.0/me/");
    }
    
    /**
     This will invoke the call to the Microsoft Graph API. It uses the
     built in URLSession to create a connection.
     */
    
    func getContentWithToken() {
        
        // Specify the Graph API endpoint
        let graphURI = getGraphEndpoint()
        let url = URL(string: graphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                self.updateLogging(text: "Couldn't get graph result: \(error)")
                return
            }
            
            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                
                self.updateLogging(text: "Couldn't deserialize result JSON")
                return
            }
            
            self.updateLogging(text: "Result from Graph: \(result))")
            
            }.resume()
    }
    
    

}
extension ViewController {
    @objc func loadAccount(_ sender: UIButton) {
        if let account = buttonToAccountMap[sender] {
            
            self.currentAccount = account
            
            self.updateCurrentAccount(account: account)
            
            //print(self.why)
            
            //guard let applicationContext = self.applicationContext else { return }
            
            /**
             
             Acquire a token for an existing account silently
             
             - forScopes:           Permissions you want included in the access token received
             in the result in the completionBlock. Not all scopes are
             guaranteed to be included in the access token returned.
             - account:             An account object that we retrieved from the application object before that the
             authentication flow will be locked down to.
             - completionBlock:     The completion block that will be called when the authentication
             flow completes, or encounters an error.
             */
            
            //self.getContentWithToken(){
            
            // }
            
            self.testAgain(self.currentAccount){ access in
                
                DispatchQueue.main.async {
                    
                    self.acquireTokenSilently(self.currentAccount)
                    self.why = access!
                    //print(self.why)
                    
                    let graphURI = "https://graph.microsoft.com/v1.0/me/onenote/sections"
                    let url = URL(string: graphURI)
                    var request = URLRequest(url: url!)
                    
                    // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
                    //print("Accont", self.currentAccount)
                    request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
                    
                    
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            
                            DispatchQueue.main.async {
                            
                            if let error = error {
                                print("Couldn't get graph result: \(error)")
                                //completion(nil)
                                return
                            }
                            
                            guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                                
                                print("Couldn't deserialize result JSON")
                                //completion(nil)
                                return
                            }
                            
                            self.userSections = []
                            
                            if let dictionary = result as? [String: Any],
                               let test = dictionary["value"] as? [[String: Any]]
                            {
                                test.forEach { numbers in
                                    //var temp = []
                                    //print(numbers["displayName"] as? String)
                                    let temp = numbers["displayName"] as? String
                                    let temp2 = numbers["id"] as? String
                                    self.userSections.append(temp!)
                                    self.sectionID.append(temp2!)
                                }
                            }
                            //self.userSections = test
                                
                                print(self.userSections)
                            
                            //print("Result from Graph: \(result.value))"
                            let photo = ViewControllerPhoto()
                            photo.currentAccount = self.currentAccount
                            photo.userSections = self.userSections
                            photo.sectionID = self.sectionID
                            
                            //self.present(photo, animated: true)
                            self.present(photo, animated: true, completion: nil)
                            
                        }
                    }.resume()
                    
                    //ViewControllerPhoto().modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
                }
            }
            
            print("WHYyyyyy", self.why)
            //ViewControllerPhoto().modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            //self.present(vc, animated: true, completion: nil)
            
            //doSomething()
        }
    }
}


// MARK: Get account and removing cache

extension ViewController {
    
    typealias AccountCompletion = (MSALAccount?) -> Void

    func loadCurrentAccount(completion: AccountCompletion? = nil) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let accountEnumerationParameters = MSALAccountEnumerationParameters()
        accountEnumerationParameters.completionBlockQueue = DispatchQueue.main
        
        self.acquireTokenInteractively()
        
        // Note that this sample showcases an app that signs in a single account at a time
        // If you're building a more complex app that signs in multiple accounts at the same time, you'll need to use a different account retrieval API that specifies account identifier
        // For example, see "accountsFromDeviceForParameters:completionBlock:" - https://azuread.github.io/microsoft-authentication-library-for-objc/Classes/MSALPublicClientApplication.html#/c:objc(cs)MSALPublicClientApplication(im)accountsFromDeviceForParameters:completionBlock:
        applicationContext.accountsFromDevice(for: accountEnumerationParameters) { (accounts, error) in
            
            if let error = error {
                self.updateLogging(text: "Couldn't retrieve accounts with error: \(error)")
                return
            }
            
            guard let accounts = accounts, !accounts.isEmpty else {
                self.updateLogging(text: "No accounts found in cache.")
                self.updateCurrentAccount(account: nil)
                self.photoButton.isEnabled = false
                self.accessToken = ""
                if let completion = completion {
                    completion(nil)
                }
                return
            }
            
            if accounts.count == 1 {
                // Single account found, use it directly
                //self.handleAccount(accounts[0], completion: completion)
                
                if let currentAccount = self.currentAccount {
                    
                    self.updateLogging(text: "Found a signed in account \(String(describing: accounts[0].username)). Updating data for that account...")
                    
                    self.acquireTokenSilently(accounts[0])
            
                    self.photoButton.isEnabled = true
                    
                    self.updateCurrentAccount(account: accounts[0])
                    
                    if let completion = completion {
                        completion(self.currentAccount)
                    }
                    
                    return
                }
                
            } else {
                // Multiple accounts found, handle appropriately (e.g., prompt user to select an account)
                
                
                
                
                for account in accounts {
                    print(account.username)
                    print(account.identifier)
                    print(account.environment)
                    print(account.homeAccountId)
                }
                //print(accounts)
                 
            }
            
            
            // If testing with Microsoft's shared device mode, see the account that has been signed out from another app. More details here:
            // https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-ios-shared-devices
            
            self.accessToken = ""
            self.updateCurrentAccount(account: nil)
            
            if let completion = completion {
                completion(nil)
            }
        }
    }
    
    
    /**
     This action will invoke the remove account APIs to clear the token cache
     to sign out a user from this application.
     */
    @objc func signOut(_ sender: UIButton) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        guard let account = self.currentAccount else { return }
        
        do {
            
            /**
             Removes all tokens from the cache for this application for the provided account
             
             - account:    The account to remove from the cache
             */
            
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!)
            
            // If testing with Microsoft's shared device mode, trigger signout from browser. More details here:
            // https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-ios-shared-devices
            
            if (self.currentDeviceMode == .shared) {
                signoutParameters.signoutFromBrowser = true
            } else {
                signoutParameters.signoutFromBrowser = false
            }
            
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                
                if let error = error {
                    self.updateLogging(text: "Couldn't sign out account with error: \(error)")
                    return
                }
                
                self.updateLogging(text: "Sign out completed successfully")
                self.accessToken = ""
                self.updateCurrentAccount(account: nil)
                self.photoButton.isEnabled = false
            })
            
        }
    }
}

// MARK: Shared Device Helpers
extension ViewController {
    
    func refreshDeviceMode() {
        
        if #available(iOS 13.0, *) {
            self.applicationContext?.getDeviceInformation(with: nil, completionBlock: { (deviceInformation, error) in
                
                guard let deviceInfo = deviceInformation else {
                    return
                }
                
                self.currentDeviceMode = deviceInfo.deviceMode
            })
        }
    }
}

// MARK: UI Helpers
extension ViewController {
    
    func initUI() {
        
        usernameLabel = UILabel()
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = ""
        usernameLabel.textColor = .clear
        usernameLabel.textAlignment = .right
        
        self.view.addSubview(usernameLabel)
        
        usernameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
        usernameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10.0).isActive = true
        usernameLabel.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // Add call Graph button
        callGraphButton  = UIButton()
        callGraphButton.translatesAutoresizingMaskIntoConstraints = false
        callGraphButton.setTitle("Sign-In with Different Account", for: .normal)
        callGraphButton.setTitleColor(.blue, for: .normal)
        callGraphButton.addTarget(self, action: #selector(callGraphAPI(_:)), for: .touchUpInside)
        callGraphButton.frame = CGRect(x: 50, y: 100, width: 200, height: 50)
        // Set the button's background color
        callGraphButton.backgroundColor = UIColor.systemBlue
        
        // Set the button's corner radius
        callGraphButton.layer.cornerRadius = 25
        
        // Set the button's shadow
        callGraphButton.layer.shadowColor = UIColor.black.cgColor
        callGraphButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        callGraphButton.layer.shadowOpacity = 0.3
        callGraphButton.layer.shadowRadius = 5
        self.view.addSubview(callGraphButton)
        
        callGraphButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        callGraphButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 400.0).isActive = true
        callGraphButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        callGraphButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        signInTitleOne = UILabel()
        signInTitleOne.translatesAutoresizingMaskIntoConstraints = false
        signInTitleOne.text = "Continue With a Previously"
        signInTitleOne.textAlignment = .center
        signInTitleOne.textColor = .darkGray
        signInTitleOne.textAlignment = .right
        
        self.view.addSubview(signInTitleOne)
        
        signInTitleOne.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInTitleOne.topAnchor.constraint(equalTo: view.topAnchor, constant: 480.0).isActive = true
        //signInTitle.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        signInTitleOne.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        signInTitleTwo = UILabel()
        signInTitleTwo.translatesAutoresizingMaskIntoConstraints = false
        signInTitleTwo.text = "Signed-in Account"
        signInTitleTwo.textAlignment = .center
        signInTitleTwo.textColor = .darkGray
        signInTitleTwo.textAlignment = .right
        
        self.view.addSubview(signInTitleTwo)
        
        signInTitleTwo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInTitleTwo.topAnchor.constraint(equalTo: view.topAnchor, constant: 505.0).isActive = true
        //signInTitle.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        signInTitleTwo.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // Add sign out button
        signOutButton = UIButton()
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.setTitle("Sign Out", for: .normal)
        //signOutButton.setTitleColor(.tr, for: .normal)
        signOutButton.setTitleColor(.clear, for: .normal)
        signOutButton.setTitleColor(.clear, for: .disabled)
        signOutButton.addTarget(self, action: #selector(signOut(_:)), for: .touchUpInside)
        self.view.addSubview(signOutButton)
        
        //signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signOutButton.topAnchor.constraint(equalTo: callGraphButton.bottomAnchor, constant: 10.0).isActive = true
        signOutButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        signOutButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        let deviceModeButton = UIButton()
        deviceModeButton.translatesAutoresizingMaskIntoConstraints = false
        deviceModeButton.setTitle("Get device info", for: .normal);
        deviceModeButton.setTitleColor(.clear, for: .normal);
        deviceModeButton.addTarget(self, action: #selector(getDeviceMode(_:)), for: .touchUpInside)
        self.view.addSubview(deviceModeButton)
        
        deviceModeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deviceModeButton.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: 10.0).isActive = true
        deviceModeButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        deviceModeButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        photoButton = UIButton()
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        photoButton.setTitle("Take Photo", for: .normal);
        photoButton.setTitleColor(.clear, for: .normal);
        photoButton.addTarget(self, action: #selector(getPhotos(_:)), for: .touchUpInside)
        self.view.addSubview(photoButton)
        
        photoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        photoButton.topAnchor.constraint(equalTo: signOutButton.bottomAnchor, constant: 50.0).isActive = true
        photoButton.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        photoButton.isEnabled = false
        
        // Add logging textfield
        
        loggingText = UITextView()
        loggingText.isUserInteractionEnabled = false
        loggingText.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(loggingText)
        
        loggingText.topAnchor.constraint(equalTo: deviceModeButton.bottomAnchor, constant: 60.0).isActive = false
        loggingText.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10.0).isActive = true
        loggingText.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10.0).isActive = true
        loggingText.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 10.0).isActive = true
        
        
    }
    
    func updateLogging(text : String) {
        
        if Thread.isMainThread {
            self.loggingText.text = text
        } else {
            DispatchQueue.main.async {
                self.loggingText.text = text
            }
        }
    }
    
    func updateSignOutButton(enabled : Bool) {
        if Thread.isMainThread {
            self.signOutButton.isEnabled = enabled
        } else {
            DispatchQueue.main.async {
                self.signOutButton.isEnabled = enabled
            }
        }
    }
    
    
    func updateAccountLabel() {
        
        guard let currentAccount = self.currentAccount else {
            self.usernameLabel.text = "Signed out"
            return
        }
        
        self.usernameLabel.text = currentAccount.username
    }
    
    func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
        self.updateAccountLabel()
        self.updateSignOutButton(enabled: account != nil)
    }
}

