//
//  Client.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 8/6/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import Foundation

class Client: NSObject {

    
    // MARK: SET BOUNDING BOX FOR LAT LONG SEARCH
    
    private func bboxString(_ latitude: Double?, _ longitude: Double?) -> String
    {
        if let lat = latitude, let long = longitude {
            let minLat = max(lat - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let minLong = max(long - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let maxLat = min(lat + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            let maxLong = min(long + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            //print("\(minLong),\(minLat),\(maxLong),\(maxLat)")
            return("\(minLong),\(minLat),\(maxLong),\(maxLat)")
        }
        return "0,0,0,0"
    }
    
    func setSearchParam(_ latitude: Double, _ longitude: Double) {
        
        var methodParameters: [String:AnyObject] = [:]
        
        let searchType = [Constants.FlickrParameterKeys.BoundingBox: bboxString(latitude,longitude)]
        let prefix = [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
                      Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey]
        let middle = [Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL]
        let postfix = [Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
                       Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback]
        
        
        methodParameters.update(other: prefix as Dictionary<String, AnyObject>)
        methodParameters.update(other: searchType as Dictionary<String, AnyObject>)
        methodParameters.update(other: middle as Dictionary<String, AnyObject>)
        
        
        methodParameters.update(other: postfix as Dictionary<String, AnyObject>)
        
        displayImageFromFlickrBySearch(methodParameters as [String : AnyObject])
        
        
    }

    
    
    // MARK: Flickr API
    // type of search int is a pathrough variable from the search type button to the set parameters function here and back again
    // search int is to let the method know to find the random page or display the random image.
    private func displayImageFromFlickrBySearch(_ methodParameters: [String: AnyObject]) {
        
        
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters))
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func displayError(_ error:String) {
                print(error)
                }
            
            // check for error
            guard (error == nil) else {
                print("There was an error:")
                displayError("\(error)" )
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let code = (response as? HTTPURLResponse)?.statusCode as! Int
                if code >= 300 && code <= 399 {
                    displayError("Your request was redirected. Error Code: \(code)")
                } else if code >= 400 && code <= 499 {
                    if code == 400 {
                        displayError("Bad Request. Error Code: \(code)")
                    } else if code == 401 {
                        displayError("Invalid Credentials. Error Code: \(code)")
                    } else if code == 403 {
                        displayError("FORBIDDEN: Check Your Credentials. Error Code: \(code)")
                    } else if code == 404 {
                        displayError("Not Found. Error Code: \(code)")
                    } else {
                        displayError("Client Error: \(code)")
                    }
                } else if code >= 500 && code <= 599 {
                    if code == 500 {
                        displayError("Internal Server Error: \(code)")
                    } else if code == 501 {
                        displayError("Not Implemented. Error Code: \(code)")
                    } else if code == 502 {
                        displayError("Bad Gateway. Error Code: \(code)")
                    } else if code == 503 {
                        displayError("Service Unavailable. Error Code: \(code)")
                    } else if code == 504 {
                        displayError("Gateway Timeout. Error Code: \(code)")
                    } else {
                        displayError("Server error: \(code)")
                    }
                } else {
                    displayError("Your request returned a status code other than 2xx! Response: \(code)")
                }
                return
            }

            
            // check for data
            guard let data = data else {
                displayError("No data was returned: \(error)" )
                return
            }
            
            // parse data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as! [String:AnyObject]
                
            } catch {
                displayError( "Could not parse JSON: '\(data)', \(error)" )
                return
            }
            
            
            // Flickr error?
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                
                displayError("Flickr returned an error in \(parsedResult)" )
                return
            }
            
            
                // check for photos and photo keys
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                    print("cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in '\(parsedResult)'")
                    return
                }
            
            print(photosDictionary)
            
            // TODO: Save photos as binary data to core data in relation to pin. 
            
            
            // random photo
            let randomPhotoIndex = Int(arc4random_uniform(uint(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
            // check for media key 'url_m' in photo
            guard let imageURLString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                print("cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in '\(parsedResult)'")
                displayError("\(error)" )
                return
            }
        }
        
        task.resume()
    }

    
    
    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    //MARK: SHARED INSTANCE
    
    
    class func sharedInstance() -> Client {
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }
    

}



// found in stackoverflow credit Rod https://stackoverflow.com/questions/24051904/how-do-you-add-a-dictionary-of-items-into-another-dictionary

// MARK: Dictionary Extension
// append items from one dictionary to another

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

