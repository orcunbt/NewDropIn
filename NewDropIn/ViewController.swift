//
//  ViewController.swift
//  NewDropIn
//
//  Created by MTS Dublin on 10/11/2016.
//  Copyright © 2016 BraintreeEMEA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var launchButton: UIButton!
    var clientTokenRetrieved:String!
    var price: Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let clientTokenURL = NSURL(string: "http://orcodevbox.co.uk/BTOrcun/tokenGen.php")!
        let clientTokenRequest = NSMutableURLRequest(URL: clientTokenURL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        
        NSURLSession.sharedSession().dataTaskWithRequest(clientTokenRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: NSUTF8StringEncoding)
            
            //self.braintreeClient = BTAPIClient(authorization: clientToken!)
            //let braintreeClient = BTAPIClient(authorization: clientToken!)
            // Log the client token to confirm that it is returned from server
            print(clientToken!);
            
            self.clientTokenRetrieved = clientToken!
            
            // As an example, you may wish to present our Drop-in UI at this point.
            // Continue to the next section to learn more...
            }.resume()
        
        

    }
    
    @IBAction func launchNewDropIn(sender: AnyObject) {
        
        showDropIn(clientTokenRetrieved)
    }
  

    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            } else if (result?.cancelled == true) {
                print("CANCELLED")
            } else if let result = result {
                // Use the BTDropInResult properties to update your UI
                
                print(result)
                let selectedPaymentOptionType = result.paymentOptionType
                
                // This is the payment nonce
                let selectedPaymentMethod = result.paymentMethod
                
                let selectedPaymentMethodIcon = result.paymentIcon
                let selectedPaymentMethodDescription = result.paymentDescription
                
                // Send nonce to server to create a transaction
                
                self.postNonceToServer(selectedPaymentMethod!)
                
            }

            controller.dismissViewControllerAnimated(true, completion: nil)
        }

        self.presentViewController(dropIn!, animated: true, completion: nil)
    }
    
    func postNonceToServer(paymentMethodNonce: BTPaymentMethodNonce) {
        price = 1300.00
        let paymentURL = NSURL(string: "http://orcodevbox.co.uk/BTOrcun/iosPayment.php")!
        let request = NSMutableURLRequest(URL: paymentURL)
        request.HTTPBody = "amount=\(Double(price))&payment_method_nonce=\(paymentMethodNonce)".dataUsingEncoding(NSUTF8StringEncoding);
        request.HTTPMethod = "POST"
        

        
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            let responseData = String(data: data!, encoding: NSUTF8StringEncoding)
            // Log the response in console
            print(responseData);
            
            // Display the result in an alert view
            dispatch_async(dispatch_get_main_queue(), {
                let alertResponse = UIAlertController(title: "Result", message: "\(responseData)", preferredStyle: UIAlertControllerStyle.Alert)
                
                // add an action to the alert (button)
                alertResponse.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                
                // show the alert
                self.presentViewController(alertResponse, animated: true, completion: nil)
                
            })
            
            }.resume()
    }

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

