//
//  ViewController.swift
//  ingredients-test
//
//  Created by Ievgen Gavrysh on 5/25/18.
//  Copyright © 2018 Ievgen Gavrysh. All rights reserved.
//

import UIKit

import Firebase

class ViewController: UIViewController, UITableViewDataSource {
  
  lazy var vision = Vision.vision()
  var textDetector: VisionTextDetector?
  
  var attributes: [String] = []
  
  @IBOutlet weak var imageURLTextField: UITextField!
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var attributesTable: UITableView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var queue = DispatchQueue.init(
    label: "my_queue",
    attributes: DispatchQueue.Attributes.concurrent
  )
  
  @IBAction func onGoButtonTouched(_ sender: UIButton) {
    
    self.activityIndicator.isHidden = false
    self.activityIndicator.startAnimating()
    let urlString = self.imageURLTextField.text ?? ""
    
    self.queue.async {
      if let data = URL.init(string: urlString)
        .flatMap({ try? Data.init(contentsOf: $0) })
      {
        DispatchQueue.main.sync {
          self.activityIndicator.stopAnimating()
          
          if let image = UIImage.init(data: data) {
            self.image.image = image
            
            self.detectAttributes(on: image)
          }
        }
      }
    }
  }
  
  func detectAttributes(on image: UIImage) {
    let visionImage = VisionImage(image: image)
      
    let metadata = VisionImageMetadata()
    metadata.orientation = .topLeft
    
    visionImage.metadata = metadata
    
    let detector = vision.textDetector()
    
    self.textDetector = detector
    
    detector.detect(in: visionImage) { (features, error) in
      guard error == nil, let features = features, !features.isEmpty else {
        // Error. You should also check the console for error messages.
        // ...
        return
      }
      
      // Recognized and extracted text
      print("Detected text has: \(features.count) blocks")
      // ...
      
      self.attributes = []
      
      for feature in features {
        if let block = feature as? VisionTextBlock {
          //print(block.text)
          for line in block.lines {
            //print(line.text)
            for element in line.elements {
              self.process(text: element.text)
            }
          }
        }
          
          // Lines contain text elements
        else if let line = feature as? VisionTextLine {
          print(line.text)
          for element in line.elements {
            self.process(text: element.text)
          }
        }
          
          // Text elements are typically words
        else if let element = feature as? VisionTextElement {
          self.process(text: element.text)
        }
      }
      
      DispatchQueue.main.async {
        self.attributesTable.reloadData()
      }
    }
  }
  
  func process(text: String) {
    self.attributes.append(text)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.activityIndicator.stopAnimating()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: -
  // MARK: UITableViewDataSource
  
  public func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int
  {
    return self.attributes.count
  }
  
  public func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = UITableViewCell.init()
    
    if indexPath.row < self.attributes.count {
      cell.textLabel?.text = self.attributes[indexPath.row]
    }
    
    return cell
  }
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
}

