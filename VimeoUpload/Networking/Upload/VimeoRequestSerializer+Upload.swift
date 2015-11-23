//
//  VimeoRequestSerializer+Upload.swift
//  VimeoUpload
//
//  Created by Alfred Hanssen on 10/21/15.
//  Copyright © 2015 Vimeo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import AVFoundation

extension VimeoRequestSerializer
{    
    func meRequest() throws -> NSMutableURLRequest
    {
        let url = NSURL(string: "/me", relativeToURL: VimeoBaseURLString)!
        var error: NSError?
        
        let request = self.requestWithMethod("GET", URLString: url.absoluteString, parameters: nil, error: &error)
        if let error = error
        {
            throw error.errorByAddingDomain(UploadErrorDomain.Me.rawValue)
        }
        
        return request
    }

    func myVideosRequest() throws -> NSMutableURLRequest
    {
        let url = NSURL(string: "/me/videos", relativeToURL: VimeoBaseURLString)!
        var error: NSError?
        
        let request = self.requestWithMethod("GET", URLString: url.absoluteString, parameters: nil, error: &error)
        if let error = error
        {
            throw error.errorByAddingDomain(UploadErrorDomain.MyVideos.rawValue)
        }
        
        return request
    }

    func createVideoRequestWithUrl(url: NSURL) throws -> NSMutableURLRequest
    {
        let parameters = try self.createVideoRequestBaseParameters(url)
        
        let url = NSURL(string: "/me/videos", relativeToURL: VimeoBaseURLString)!

        return try self.createVideoRequestWithUrl(url, parameters: parameters)
    }

    func createVideoRequestWithUrl(url: NSURL, parameters: [String: AnyObject]) throws -> NSMutableURLRequest
    {
        var error: NSError?
        let request = self.requestWithMethod("POST", URLString: url.absoluteString, parameters: parameters, error: &error)

        if let error = error
        {
            throw error.errorByAddingDomain(UploadErrorDomain.Create.rawValue)
        }
        
        return request
    }

    func createVideoRequestBaseParameters(url: NSURL) throws -> [String: AnyObject]
    {
        let asset = AVURLAsset(URL: url)
        
        var fileLength: NSNumber?
        do
        {
            fileLength = try asset.fileSize()
        }
        catch let error as NSError
        {
            throw error.errorByAddingDomain(UploadErrorDomain.Create.rawValue)
        }
        
        guard let aFileLength = fileLength else
        {
            throw NSError(domain: UploadErrorDomain.Create.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to calculate file length."])
        }
        
        return ["type": "streaming", "size": aFileLength]
    }

    func uploadVideoRequestWithSource(source: NSURL, destination: String) throws -> NSMutableURLRequest
    {
        guard let path = source.path where NSFileManager.defaultManager().fileExistsAtPath(path) else
        {
            throw NSError(domain: UploadErrorDomain.Upload.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "Attempt to construct upload request but the source file does not exist."])
        }
        
        var error: NSError?
        let request = self.requestWithMethod("PUT", URLString: destination, parameters: nil, error: &error)
        if let error = error
        {
            throw error.errorByAddingDomain(UploadErrorDomain.Upload.rawValue)
        }
        
        let asset = AVURLAsset(URL: source)
        
        var fileLength: NSNumber?
        do
        {
            fileLength = try asset.fileSize()
        }
        catch let error as NSError
        {
            throw error.errorByAddingDomain(UploadErrorDomain.Upload.rawValue)
        }
        
        guard let aFileLength = fileLength else
        {
            throw NSError(domain: UploadErrorDomain.Upload.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to calculate file length."])
        }
        
        request.setValue("\(aFileLength)", forHTTPHeaderField: "Content-Length")
        request.setValue("video/mp4", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func activateVideoRequestWithUri(uri: String) throws -> NSMutableURLRequest
    {
        let url = NSURL(string: uri, relativeToURL: VimeoBaseURLString)!
        var error: NSError?
        
        let request = self.requestWithMethod("DELETE", URLString: url.absoluteString, parameters: nil, error: &error)
        if let error = error
        {
            throw error.errorByAddingDomain(UploadErrorDomain.Activate.rawValue)
        }
        
        return request
    }

    func videoSettingsRequestWithUri(videoUri: String, videoSettings: VideoSettings) throws -> NSMutableURLRequest
    {
        guard videoUri.characters.count > 0 else 
        {
            throw NSError(domain: UploadErrorDomain.VideoSettings.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "videoUri has length of 0."])
        }
        
        let url = NSURL(string: videoUri, relativeToURL: VimeoBaseURLString)!
        var error: NSError?

        let parameters = videoSettings.parameterDictionary()
        if parameters.count == 0
        {
            throw NSError(domain: UploadErrorDomain.VideoSettings.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "Parameters dictionary is empty."])
        }
        
        let request = self.requestWithMethod("PATCH", URLString: url.absoluteString, parameters: parameters, error: &error)
        if let error = error
        {
            throw error.errorByAddingDomain(UploadErrorDomain.VideoSettings.rawValue)
        }
        
        return request
    }
    
    func deleteVideoRequestWithUri(videoUri: String) throws -> NSMutableURLRequest
    {
        guard videoUri.characters.count > 0 else
        {
            throw NSError(domain: UploadErrorDomain.Delete.rawValue, code: 0, userInfo: [NSLocalizedDescriptionKey: "videoUri has length of 0."])
        }
        
        let url = NSURL(string: videoUri, relativeToURL: VimeoBaseURLString)!
        var error: NSError?
        
        let request = self.requestWithMethod("DELETE", URLString: url.absoluteString, parameters: nil, error: &error)
        if let error = error
        {
            throw error.errorByAddingDomain(UploadErrorDomain.Delete.rawValue)
        }
        
        return request
    }
}