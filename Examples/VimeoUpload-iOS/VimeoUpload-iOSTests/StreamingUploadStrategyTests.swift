//
//  StreamingUploadStrategyTests.swift
//  VimeoUpload-iOSTests
//
//  Created by Nguyen, Van on 11/13/18.
//  Copyright © 2018 Vimeo. All rights reserved.
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

import XCTest
@testable import VimeoNetworking
@testable import VimeoUpload

class StreamingUploadStrategyTests: XCTestCase
{
    func test_uploadLink_returnsStreamingLink_whenStreamingLinkIsAvailable()
    {
        let video = self.videoObject(fromResponseWithFile: "clip_streaming.json")
        
        XCTAssertEqual(try StreamingUploadStrategy.uploadLink(from: video), "https://www.google.com", "`uploadLink` should have returned a streaming link.")
    }
    
    func test_uploadLink_throwsWrongTypeError_whenUploadApproachIsDifferentFromStreaming()
    {
        let video = self.videoObject(fromResponseWithFile: "clip_tus.json")
        
        XCTAssertThrowsError(try StreamingUploadStrategy.uploadLink(from: video), "`uploadLink` should have thrown.") { error in
            XCTAssertEqual(error as? UploadLinkError, .wrongType, "The error should have been `wrongType`.")
        }
    }
    
    func test_uploadLink_throwsUnavailableError_whenStreamingLinkIsNotAvailable()
    {
        let video = self.videoObject(fromResponseWithFile: "clip_streaming_no_link.json")
        
        XCTAssertThrowsError(try StreamingUploadStrategy.uploadLink(from: video), "`uploadLink` should have thrown.") { error in
            XCTAssertEqual(error as? UploadLinkError, .unavailable, "The error should have been `unavailable`.")
        }
    }
    
    func test_uploadRequest_throwsError_whenRequestSerializerIsNotAvailable()
    {
        guard let fileUrl = Bundle(for: type(of: self)).url(forResource: "wide_worlds", withExtension: "mp4") else
        {
            fatalError("Error: Cannot get file's URL.")
        }
        
        let video = self.videoObject(fromResponseWithFile: "clip_streaming.json")
        
        guard let uploadLink = video.upload?.uploadLink else
        {
            fatalError("Error: Cannot get an upload link.")
        }
        
        XCTAssertThrowsError(try StreamingUploadStrategy.uploadRequest(requestSerializer: nil, fileUrl: fileUrl, uploadLink: uploadLink), "`uploadRequest` should have thrown.")
    }
    
    private func videoObject(fromResponseWithFile fileName: String) -> VIMVideo
    {
        do
        {
            let bundle = Bundle(for: type(of: self))
            
            guard let jsonUrl = bundle.url(forResource: fileName, withExtension: nil) else
            {
                fatalError("Error: File not found.")
            }
            
            let data = try Data(contentsOf: jsonUrl)
            
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else
            {
                fatalError("Error: Dictionary object cannot be created.")
            }
            
            return try VIMObjectMapper.mapObject(responseDictionary: dictionary) as VIMVideo
        }
        catch let error
        {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
}
