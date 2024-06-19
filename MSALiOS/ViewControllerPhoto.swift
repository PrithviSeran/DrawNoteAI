//
//  ViewControllerPhoto.swift
//  MSALiOS
//
//  Created by PrithviSeran on 2024-05-27.
//  Copyright © 2024 Microsoft. All rights reserved.
//

import UIKit
import Foundation
import MSAL

class ViewControllerPhoto: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    private var photoButton: UIButton!
    private var cameraButton: UIButton!
    private var pageNameButton: UIButton!
    private var titleText: UILabel!
    private var bodyText: UILabel!
    private var imagePicker: UIImagePickerController!
    private var spinner: UIActivityIndicatorView!
    private var activityIndicatorBackground: UIView!
    private var backButton: UIButton!
    private var textURL = "vision/v2.0/read/core/asyncBatchAnalyze";
    private var header: UILabel!
    private var chooseSection: UILabel!
    var sectionIdIndic: UILabel!
    var pageNameIndic: UILabel!
    var currentAccount: MSALAccount?
    var accessToken = ""
    @IBOutlet var pageName: String!
    
    // Update the below to your client ID you received in the portal. The below is for running the demo only
    let kClientID = "9ee9fb26-38bc-459b-9e11-0fb8457b68ff"
    let kGraphEndpoint = "https://graph.microsoft.com/"
    let kAuthority = "https://login.microsoftonline.com/common"
    let kRedirectUri = "msauth.Prince.PrinceNotes://auth"
    
    let kScopes: [String] = ["user.read", "Notes.Create", "Notes.ReadWrite", "Notes.ReadWrite.All"] //
    
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    
    var userSections: [String] = []
    var sectionID: [String] = []
    var buttonToSectionIdMap = [UIButton: String]()
    var buttonToSectionNameMap = [UIButton: String]()
    
    var sectionIdEntered = false
    var pageNameEntered = false
    
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            print("Unable to create authority URL")
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
    
    //@IBOutlet var textField: UITextField!
    //@IBOutlet weak var textView: UITextView!
    
    @IBAction func CloseModal(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
      }
    
    
    // Create UITextField and UIButton programmatically
        let userTextField: UITextField = {
            let textField = UITextField()
            textField.placeholder = "Enter text"
            textField.borderStyle = .roundedRect
            textField.translatesAutoresizingMaskIntoConstraints = false
            return textField
        }()
        
        let submitButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Submit", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try self.initMSAL()
        } catch let error {
            print( "Unable to create Application Context \(error)")
        }
        
        view.backgroundColor = .white
        
        titleText = UILabel()
        titleText.text = "Picture to Immersive Reader with OCR"
        titleText.font = UIFont.boldSystemFont(ofSize: 32)
        titleText.textAlignment = .center
        titleText.lineBreakMode = .byWordWrapping
        titleText.numberOfLines = 0
        view.addSubview(titleText)
        
        bodyText = UILabel()
        bodyText.text = "Capture or upload a photo of handprinted text on a piece of paper, handwriting, typed text, text on a computer screen, writing on a white board and many more, and watch it be presented to you in the Immersive Reader!"
        bodyText.font = UIFont.systemFont(ofSize: 18)
        bodyText.lineBreakMode = .byWordWrapping
        bodyText.numberOfLines = 0
        let screenSize = self.view.frame.height
        if screenSize <= 667 {
            // Font size for smaller iPhones.
            bodyText.font = bodyText.font.withSize(16)

        } else if screenSize <= 812.0 {
            // Font size for medium iPhones.
            bodyText.font = bodyText.font.withSize(18)
            
        } else if screenSize <= 896  {
            // Font size for larger iPhones.
            bodyText.font = bodyText.font.withSize(20)
            
        } else {
            // Font size for iPads.
            bodyText.font = bodyText.font.withSize(26)
        }
        view.addSubview(bodyText)
        
        
        header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Enter The Name of Your \n New OneNote Page:"
        header.textAlignment = .center
        header.lineBreakMode = .byWordWrapping
        header.numberOfLines = 2
        header.textColor = .darkGray
        
        //self.view.addSubview(header)
        
        /*
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: 455.0).isActive = true
        //signInTitle.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        header.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        */
        
        chooseSection = UILabel()
        chooseSection.translatesAutoresizingMaskIntoConstraints = false
        chooseSection.text = "Choose Your Section:"
        chooseSection.textAlignment = .center
        chooseSection.lineBreakMode = .byWordWrapping
        chooseSection.numberOfLines = 2
        chooseSection.textColor = .darkGray
        
        self.view.addSubview(chooseSection)
        
        chooseSection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        chooseSection.topAnchor.constraint(equalTo: view.topAnchor, constant: 135.0).isActive = true
        //signInTitle.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        chooseSection.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        sectionIdIndic = UILabel()
        sectionIdIndic.translatesAutoresizingMaskIntoConstraints = false
        sectionIdIndic.text = ""
        sectionIdIndic.textAlignment = .center
        sectionIdIndic.lineBreakMode = .byWordWrapping
        sectionIdIndic.numberOfLines = 2
        sectionIdIndic.textColor = .darkGray
        
        self.view.addSubview(sectionIdIndic)
        
        sectionIdIndic.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sectionIdIndic.topAnchor.constraint(equalTo: view.topAnchor, constant: 410.0).isActive = true
        //signInTitle.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        sectionIdIndic.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        pageNameIndic = UILabel()
        pageNameIndic.translatesAutoresizingMaskIntoConstraints = false
        pageNameIndic.text = ""
        pageNameIndic.textAlignment = .center
        pageNameIndic.lineBreakMode = .byWordWrapping
        pageNameIndic.numberOfLines = 2
        pageNameIndic.textColor = .darkGray
        
        self.view.addSubview(pageNameIndic)
        
        pageNameIndic.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageNameIndic.topAnchor.constraint(equalTo: view.topAnchor, constant: 560.0).isActive = true
        //signInTitle.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        pageNameIndic.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        pageNameButton = UIButton()
        pageNameButton.backgroundColor = .darkGray
        pageNameButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        pageNameButton.layer.cornerRadius = 5
        pageNameButton.setTitleColor(.white, for: .normal)
        pageNameButton.setTitle("Enter the Name of Your Page", for: .normal)
        pageNameButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        pageNameButton.addTarget(self, action: #selector(getName(_:)), for: .touchUpInside)
        view.addSubview(pageNameButton)
        
        pageNameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageNameButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 500.0).isActive = true
        pageNameButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        pageNameButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        pageNameButton.translatesAutoresizingMaskIntoConstraints = false
        
        photoButton = UIButton()
        photoButton.backgroundColor = .darkGray
        photoButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        photoButton.layer.cornerRadius = 5
        photoButton.setTitleColor(.white, for: .normal)
        photoButton.setTitle("Choose Photo from Library", for: .normal)
        photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        photoButton.addTarget(self, action: #selector(selectPhotoButton(sender:)), for: .touchUpInside)
        view.addSubview(photoButton)
        
        
        cameraButton = UIButton()
        backButton = UIButton()
        
        cameraButton = UIButton()
        cameraButton.backgroundColor = .darkGray
        cameraButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        cameraButton.layer.cornerRadius = 5
        cameraButton.setTitleColor(.white, for: .normal)
        cameraButton.setTitle("Take Photo", for: .normal)
        cameraButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        cameraButton.addTarget(self, action: #selector(takePhotoButton(sender:)), for: .touchUpInside)
         
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        backButton.layer.cornerRadius = 5
        backButton.setTitleColor(.blue, for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        backButton.addTarget(self, action: #selector(CloseModal(_:)), for: .touchUpInside)
         
        cameraButton.backgroundColor = .darkGray
        view.addSubview(cameraButton)
        view.addSubview(backButton)
        
        photoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        photoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 700.0).isActive = true
        photoButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        
        cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 625.0).isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -185.0).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50.0).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        for (index, name) in self.userSections.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(name, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            //self.buttonToAccountMap[button] = account
            self.buttonToSectionIdMap[button] = sectionID[index]
            self.buttonToSectionNameMap[button] = name
            button.addTarget(self, action: #selector(self.uploadSectionId(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            scrollView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            scrollView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -130),
            scrollView.widthAnchor.constraint(equalToConstant: 400), // Correct way to set width
            scrollView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        
        // Set constraints for UIStackView
        NSLayoutConstraint.activate([
            
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20) // For horizontal scrolling
        ])
        
        // Add the UITextField and UIButton to the view
        //view.addSubview(userTextField)
        //view.addSubview(submitButton)
        
        // Set up constraints
        //setupConstraints()
        
        // Add target action for the button
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        // Create content and options.
    }
    
    func setupConstraints() {
        // Constraints for userTextField
        NSLayoutConstraint.activate([
            userTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 120),
            userTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Constraints for submitButton
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: userTextField.bottomAnchor, constant: 20),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func submitButtonTapped() {
        // Get the text from the UITextField
        if let userInput = userTextField.text {
            print("User input: \(userInput)")
        }
    }
    
    @objc func getName( _ sender: UIButton){
        let alert = UIAlertController(title: "OneNote Page", message: "Enter the Name of Your Page", preferredStyle: .alert)
                                        
        //add textFields in alert alert. addTextField()
        
        alert.addTextField()
        //alert.addTextField()
        //set properties of textFields like hint and input type of textFields
        alert.textFields![0].placeholder = "Name"
        //alert.textFields![0].keyboardType = UIKeyboardType.emailAddress
        //alert.textFields![1].placeholder = "Enter Password"
        //alert.textFields![1].isSecureTextEntry = true
                                        //add action buttons e.g. Save, Cancel
        
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            print ("Canceled...") //show on log
          }))
        /*
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action) in
            print ("Canceled...") //show on log
          }))
         */
        
        alert.addAction(UIAlertAction(title: "Enter", style: .default, handler: {(action) in
            //get text from textFields on alert
            let pageName = alert.textFields![0].text
            //let passwText = alert.textFields![1].text
            //set to textView
            self.pageName = pageName!
            
            self.pageNameIndic.text = self.pageName
            self.pageNameIndic.textColor = .darkGray
            
            let accountName = "princenotes2"
            let containerName = "rundnnmodel"
            let sasToken = "sp=rcw&st=2024-06-11T01:39:14Z&se=2025-06-01T09:39:14Z&sv=2022-11-02&sr=c&sig=6ohLBbuDkcd11CJfp5b3yE8kKEmfQDqN3n2W3yII%2BsM%3D"
            
            // Define the image path and the blob name
            //let imagePath = "/Users/prithviseran/Downloads/unnamed.jpg"
            let blobName = "pageName.txt"
            
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
            
            
            
            guard let dataToUpload = self.pageName.data(using: .utf8) else {
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
                        self.pageNameEntered = true
                        print(self.pageName.data(using: .utf8))
                    } else {
                        print("Upload failed with status code: \(httpResponse.statusCode)")
                        print(httpResponse)
                    }
                }
            }
            
            uploadTask.resume()
        }))
        
        self.present(alert, animated: true)
    }
    
    // Dismiss the keyboard when the user taps outside the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func uploadSectionId(_ sender: UIButton){
            
        self.sectionIdEntered = true
        
            if let id = buttonToSectionIdMap[sender] {
                
                self.sectionIdIndic.text = self.buttonToSectionNameMap[sender]
                self.sectionIdIndic.textColor = .darkGray
                
                print("Section id: ", id)
                
                let accountName = "princenotes2"
                let containerName = "rundnnmodel"
                let sasToken = "sp=rcw&st=2024-06-11T01:39:14Z&se=2025-06-01T09:39:14Z&sv=2022-11-02&sr=c&sig=6ohLBbuDkcd11CJfp5b3yE8kKEmfQDqN3n2W3yII%2BsM%3D"
                
                // Define the image path and the blob name
                //let imagePath = "/Users/prithviseran/Downloads/unnamed.jpg"
                let blobName = "sectionId.txt"
                
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
                
                
                
                guard let dataToUpload = id.data(using: .utf8) else {
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
                            print(id.data(using: .utf8))
                        } else {
                            print("Upload failed with status code: \(httpResponse.statusCode)")
                            print(httpResponse)
                        }
                    }
                }
                
                uploadTask.resume()
            }
        
    }
    
    /*
    func checkInfoEntered(){
        if !self.pageNameEntered && !self.sectionIdEntered {
            self.sectionIdIndic.text = "Please Enter the Section!"
            self.sectionIdIndic.textColor = .red
            self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            self.pageNameIndic.textColor = .red
            
            return
        }
        else if !self.pageNameEntered{
            //self.sectionIdIndic.text = "Please Enter the Section!"
            self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            self.pageNameIndic.textColor = .red
            return
        }
        else if !self.sectionIdEntered {
            self.sectionIdIndic.text = "Please Enter the Section!"
            self.sectionIdIndic.textColor = .red
            //self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            
            return
        }
    }
    */
    
    
    @IBAction func selectPhotoButton(sender: AnyObject) {
        if !self.pageNameEntered && !self.sectionIdEntered {
            self.sectionIdIndic.text = "Please Enter the Section!"
            self.sectionIdIndic.textColor = .red
            self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            self.pageNameIndic.textColor = .red
            
            return
        }
        else if !self.pageNameEntered{
            //self.sectionIdIndic.text = "Please Enter the Section!"
            self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            self.pageNameIndic.textColor = .red
            return
        }
        else if !self.sectionIdEntered {
            self.sectionIdIndic.text = "Please Enter the Section!"
            self.sectionIdIndic.textColor = .red
            //self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            
            return
        }
        // Launch the photo picker.
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        self.present(self.imagePicker, animated: true, completion: nil)
        //self.photoButton.isEnabled = true
    }
    
    @IBAction func takePhotoButton(sender: AnyObject) {
        if !self.pageNameEntered && !self.sectionIdEntered {
            self.sectionIdIndic.text = "Please Enter the Section!"
            self.sectionIdIndic.textColor = .red
            self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            self.pageNameIndic.textColor = .red
            
            return
        }
        else if !self.pageNameEntered{
            //self.sectionIdIndic.text = "Please Enter the Section!"
            self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            self.pageNameIndic.textColor = .red
            return
        }
        else if !self.sectionIdEntered {
            self.sectionIdIndic.text = "Please Enter the Section!"
            self.sectionIdIndic.textColor = .red
            //self.pageNameIndic.text = "Please Enter the Name of Your Page!"
            
            return
        }
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            // If there is no camera on the device, disable the button
            self.cameraButton.backgroundColor = .gray
            self.cameraButton.isEnabled = true
            
        } else {
            // Launch the camera.
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
            self.cameraButton.isEnabled = true
        }
        
        print("Why???")
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        imagePicker.dismiss(animated: true, completion: nil)
        photoButton.isEnabled = false
        cameraButton.isEnabled = false
        //self.spinner.startAnimating()
        //activityIndicatorBackground.alpha = 0.6
        
        // Retrieve the image.
        let image = (info[.originalImage] as? UIImage)!
        
        // Retrieve the byte array from image.
        let imageByteArray = image.jpegData(compressionQuality: 1.0)
        
        
        print("Over Here!!!!!!!!")
        
        self.photoButton.isEnabled = true
        self.cameraButton.isEnabled = true
        
      
        
        //return
        
        
        // Call the getTextFromImage function passing in the image the user takes or chooses.
        getTextFromImage(subscriptionKey: "Dummy", getTextUrl: "Dummy-EndPoint", pngImage: imageByteArray!, onSuccess: { cognitiveText in
            print("cognitive text is: \(cognitiveText)")
            DispatchQueue.main.async {
                self.photoButton.isEnabled = true
                self.cameraButton.isEnabled = true
            }
            
        }, onFailure: { error in
            DispatchQueue.main.async {
                self.photoButton.isEnabled = true
                self.cameraButton.isEnabled = true
            }
            
        })
         
    }
    
    
    func getTextFromImage(subscriptionKey: String, getTextUrl: String, pngImage: Data, onSuccess: @escaping (_ theToken: String) -> Void, onFailure: @escaping ( _ theError: String) -> Void) {
        
        /*
        let url = URL(string: getTextUrl)!
        var request = URLRequest(url: url)
        request.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // Two REST API calls are required to extract text. The first call is to submit the image for processing, and the next call is to retrieve the text found in the image.
        
        // Set the body to the image in byte array format.
        request.httpBody = pngImage
        
        request.httpMethod = "POST"
        */
        //
        // Define your account and SAS token
        let accountName = "princenotes2"
        let containerName = "rundnnmodel"
        let sasToken = "sp=rcw&st=2024-06-11T01:39:14Z&se=2025-06-01T09:39:14Z&sv=2022-11-02&sr=c&sig=6ohLBbuDkcd11CJfp5b3yE8kKEmfQDqN3n2W3yII%2BsM%3D"

        // Define the image path and the blob name
        //let imagePath = "/Users/prithviseran/Downloads/unnamed.jpg"
        let blobName = "user_image.jpg"

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
        request.setValue("image/png", forHTTPHeaderField: "Content-Type") // text/plain
        

        // Upload the image
        let uploadTask = URLSession.shared.uploadTask(with: request, from: pngImage) { data, response, error in
            if let error = error {
                print("Upload failed with error: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("Image uploaded successfully.")
                } else {
                    print("Upload failed with status code: \(httpResponse.statusCode)")
                    print(httpResponse)
                }
            }
        }

        uploadTask.resume()
        
        
        /*
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                // Check for networking errors.
                error == nil else {
                    print("error", error ?? "Unknown error")
                    onFailure("Error")
                    return
            }
            
            // Check for http errors.
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                onFailure(String(response.statusCode))
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString!))")
            
            // Send the second call to the API. The first API call returns operationLocation which stores the URI for the second REST API call.
            let operationLocation = response.allHeaderFields["Operation-Location"] as? String
            
            if (operationLocation == nil) {
                print("Error retrieving operation location")
                return
            }
            
            // Wait 10 seconds for text recognition to be available as suggested by the Text API documentation.
            print("Text submitted. Waiting 10 seconds to retrieve the recognized text.")
            sleep(10)
            
            // HTTP GET request with the operationLocation url to retrieve the text.
            let getTextUrl = URL(string: operationLocation!)!
            var getTextRequest = URLRequest(url: getTextUrl)
            getTextRequest.setValue(subscriptionKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
            getTextRequest.httpMethod = "GET"
            
            // Send the GET request to retrieve the text.
            let taskGetText = URLSession.shared.dataTask(with: getTextRequest) { data, response, error in
                guard let data = data,
                    let response = response as? HTTPURLResponse,
                    // Check for networking errors.
                    error == nil else {
                        print("error", error ?? "Unknown error")
                        onFailure("Error")
                        return
                }
                
                // Check for http errors.
                guard (200 ... 299) ~= response.statusCode else {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    onFailure(String(response.statusCode))
                    return
                }
                
                // Decode the JSON data into an object.
                let customDecoding = try! JSONDecoder().decode(TextApiResponse.self, from: data)
                
                // Loop through the lines to get all lines of text and concatenate them together.
                var textFromImage = ""
                for textLine in customDecoding.recognitionResults[0].lines {
                    textFromImage = textFromImage + textLine.text + " "
                }
                
                onSuccess(textFromImage)
            }
            taskGetText.resume()
        

        }
        
        task.resume()
         */
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
