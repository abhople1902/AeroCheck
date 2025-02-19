//
//  ViewController.swift
//  AeroCheck
//
//  Created by Ayush Bhople on 30/08/23.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var faultClass: UILabel!
    @IBOutlet weak var firstView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            firstView.image = userPickedImage
            
            let imageData = userPickedImage.jpegData(compressionQuality: 1)
            let fileContent = imageData?.base64EncodedString()
            let postData = fileContent!.data(using: .utf8)
            
            
            var request = URLRequest(url: URL(string: "https://detect.roboflow.com/innovation-hangar-v2/1?api_key=V5UUWMksYOC3S27kgKvW&name=YOUR_IMAGE.jpg")!,timeoutInterval: Double.infinity)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            
            
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in

                
                guard let data = data else {
                    print(String(describing: error))
                    return
                }

                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let predictions = json["predictions"] as? [[String: Any]],
                       let firstPrediction = predictions.first,
                       let classValue = firstPrediction["class"] as? String {
                        
                        print("Class: \(classValue)")
                        DispatchQueue.main.async {
                            self.faultClass.text = classValue
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
                // print(String(data: data, encoding: .utf8)!)
            }).resume()
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
//    @IBAction func buttonAPIPressed(_ sender: UIButton) {
//        let backendURLString = "http://192.168.29.241:3000/repairs/newfault"
//            guard let backendURL = URL(string: backendURLString) else {
//                print("Invalid backend URL")
//                return
//            }
//
//            // Prepare data to send in the request body
//            let labelText = faultClass.text ?? ""
//            let requestData: [String: Any] = ["name": labelText]
//            print(requestData)
//            
//            do {
//                // Serialize the data into JSON
//                let jsonData = try JSONSerialization.data(withJSONObject: requestData, options: [])
//
//                // Create a URLRequest with the backend URL
//                var request = URLRequest(url: backendURL)
//                request.httpMethod = "POST"
//                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//                request.httpBody = jsonData
//
//                // Send the request
//                URLSession.shared.dataTask(with: request) { data, response, error in
//                    if let error = error {
//                        print("Error: \(error)")
//                        return
//                    }
//
//                    // Handle the response
//                    if let httpResponse = response as? HTTPURLResponse {
//                        print("Status code: \(httpResponse.statusCode)")
//                        // Process the response data if needed
//                    }
//                }.resume()
//            } catch {
//                print("Error serializing JSON: \(error)")
//            }
//    }
    
    
}

