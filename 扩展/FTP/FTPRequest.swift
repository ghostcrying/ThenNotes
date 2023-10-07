//
//  FTPRequest.swift
//  HUDClient
//
//  Created by Enjoy on 2018/12/5.
//  Copyright © 2018 YuanGu. All rights reserved.
//

import UIKit
import Foundation

fileprivate let ListsBufferSize: Int = 1024*2    // 最初设定1024
fileprivate let DownloadBufferSize: Int = 1024*2 // 每一帧下载size
fileprivate let UploadBufferSize: Int = 1024*5   // 最初设定1024

typealias ProgressClosure = (_ total: Int, _ finish: Int, _ progress: CGFloat) -> ()
typealias SuccessClosure = (_ result: Any?) -> ()
typealias FailerClosure = (_ domin: CFStreamErrorDomain, _ error: Int, _ description: String) -> ()

enum FileType {
    case file
    case txt, plist, zip
    case mp4, jpeg, jpg, png
    case other
}

class FileSource {
    
    var type: Int = 0
    var mode: Int = 0
    var size: Int = 0  // byte number
    var modDate: String = "" // 2018-12-05 07:00:00 +0000
    var link:  String = ""
    var group: String = ""
    var name:  String = ""
    var owner: String = ""
    var fileType = FileType.file
}

class FTPRequest: NSObject {
    
    static let shared = FTPRequest()
    
    var user: String!
    var pass: String!
    var server: URL!
    var totalSize: Int = 0 // download total size
    var finishSize: Int = 0
    
    var streamClientContext = CFStreamClientContext()
    var readsStream: CFReadStream!
    var writeStream: CFWriteStream!
    
    var progress: ProgressClosure!
    var success: SuccessClosure!
    var failer: FailerClosure!
    
    var readData = NSMutableData()
    
    override init() {
        super.init()
        self.streamClientContext.info = UnsafeMutableRawPointer(mutating: UnsafeRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
    deinit {
        print("\(#file) release")
    }
    
    func updateInfo(_ user: String = "", _ pass: String = "", server: URL!) {
        self.user = user
        self.pass = pass
        self.server = server
    }
}

extension FTPRequest {
    func getErrorDescription(code: Int) -> String {
        switch (code) {
        case 110:
            return "Restart marker reply. In this case, the text is exact and not left to the particular implementation it must read: MARK yyyy = mmmm where yyyy is User-process data stream marker, and mmmm server's equivalent marker (note the spaces between markers and \"=\")."
        case 120:
            return "Service ready in nnn minutes."
        case 125:
            return "Data connection already open transfer starting."
        case 150:
            return "File status okay about to open data connection."
        case 200:
            return "Command okay."
        case 202:
            return "Command not implemented, superfluous at this site."
        case 211:
            return "System status, or system help reply."
        case 212:
            return "Directory status."
        case 213:
            return "File status."
        case 214:
            return "Help message. On how to use the server or the meaning of a particular non-standard command. This reply is useful only to the human user."
        case 215:
            return "NAME system type. Where NAME is an official system name from the list in the Assigned Numbers document."
        case 220:
            return "Service ready for new user."
        case 221:
            return "Service closing control connection."
        case 225:
            return "Data connection open no transfer in progress."
        case 226:
            return "Closing data connection. Requested file action successful (for example, file transfer or file abort)."
        case 227:
            return "Entering Passive Mode."
        case 230:
            return "User logged in, proceed. Logged out if appropriate."
        case 250:
            return "Requested file action okay, completed."
        case 257:
            return "\"PATHNAME\" created."
        case 331:
            return "User name okay, need password."
        case 332:
            return "Need account for login."
        case 350:
            return "Requested file action pending further information."
        case 421:
            return "Service not available, closing control connection.This may be a reply to any command if the service knows it must shut down."
        case 425:
            return "Can't open data connection."
        case 426:
            return "Connection closed transfer aborted."
        case 450:
            return "Requested file action not taken."
        case 451:
            return "Requested action aborted. Local error in processing."
        case 452:
            return "Requested action not taken. Insufficient storage space in system.File unavailable (e.g., file busy)."
        case 500:
            return "Syntax error, command unrecognized. This may include errors such as command line too long."
        case 501:
            return "Syntax error in parameters or arguments."
        case 502:
            return "Command not implemented."
        case 503:
            return "Bad sequence of commands."
        case 504:
            return "Command not implemented for that parameter."
        case 530:
            return "Not logged in."
        case 532:
            return "Need account for storing files."
        case 550:
            return "Requested action not taken. File unavailable (e.g., file not found, no access)."
        case 551:
            return "Requested action aborted. Page type unknown."
        case 552:
            return "Requested file action aborted. Exceeded storage allocation (for current directory or dataset)."
        case 553:
            return "Requested action not taken. File name not allowed."
        default:
            return "Unknown"
        }
    }

    func getFileSource(_ dict: CFDictionary) -> FileSource? {
        guard let result = dict as? [String: AnyObject] else { return nil }
        let source = FileSource()
        source.fileType = .other
        if let link = result[kCFFTPResourceLink as String] {
            source.link = link as! String
        }
        if let group = result[kCFFTPResourceGroup as String] {
            source.group = group as! String
        }
        if let modDate = result[kCFFTPResourceModDate as String] {
            source.modDate = modDate as! String
        }
        if let mode = result[kCFFTPResourceMode as String] {
            source.mode = mode as! Int
        }
        if let name = result[kCFFTPResourceName as String] {
            source.name = name as! String
            if source.name.hasSuffix(".mp4") {
                source.fileType = .mp4
            } else if source.name.hasSuffix(".txt") {
                source.fileType = .txt
            } else if source.name.hasSuffix(".plist") {
                source.fileType = .plist
            } else if source.name.hasSuffix(".zip") {
                source.fileType = .zip
            } else if source.name.hasSuffix(".jpeg") {
                source.fileType = .jpeg
            } else if source.name.hasSuffix(".png") {
                source.fileType = .png
            }
        }
        if let owner = result[kCFFTPResourceOwner as String] {
            source.owner = owner as! String
        }
        if let size = result[kCFFTPResourceSize as String] {
            source.size = size as! Int
        }
        if let type = result[kCFFTPResourceType as String] {
            source.type = type as! Int
            if source.type == 4 {
                source.fileType = .file
            }
        }
        return source
    }
}

// MARK: - Read
extension FTPRequest {
    public func readLists(success: @escaping (SuccessClosure), progress: @escaping (ProgressClosure), failer: @escaping(FailerClosure)) -> Bool {
        self.readsStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, server as CFURL)
        self.success = success
        self.progress = progress
        self.failer = failer
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPUserName), user as CFTypeRef)
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPPassword), pass as CFTypeRef)
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPFetchResourceInfo), true as CFTypeRef)
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPAttemptPersistentConnection), false as CFTypeRef)
        
        let registeredEvents: CFOptionFlags =
                CFStreamEventType.canAcceptBytes.rawValue |
                CFStreamEventType.hasBytesAvailable.rawValue |
                CFStreamEventType.errorOccurred.rawValue |
                CFStreamEventType.endEncountered.rawValue
        let supportsAsynchronousNotification = CFReadStreamSetClient(readsStream, registeredEvents, { (stream, event, data) in
            let myself = Unmanaged<FTPRequest>.fromOpaque(data!).takeUnretainedValue()
            switch event {
            case CFStreamEventType.hasBytesAvailable:
                let buffer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>(bitPattern: ListsBufferSize)!
                let byteRead = CFReadStreamRead(stream, buffer, ListsBufferSize)
                var resources = [FileSource]()
                if byteRead > 0
                {
                    myself.readData.append(buffer, length: byteRead)
                    myself.progress(0, myself.readData.length, 0)
                }
                else if byteRead == 0
                {
                    var offset = 0
                    let totalBytes = CFIndex(myself.readData.length)
                    let entity = UnsafeMutablePointer<Unmanaged<CFDictionary>?>.allocate(capacity: 1)
                    let bytes = myself.readData.bytes.bindMemory(to: UInt8.self, capacity: totalBytes)
                    var parsedBytes = CFIndex(0)
                    repeat {
                        parsedBytes = CFFTPCreateParsedResourceListing(nil, bytes.advanced(by: offset), totalBytes-offset, entity)
                        if parsedBytes > 0 {
                            let value = entity.pointee?.takeUnretainedValue()
                            if let fptResource = value, let source = myself.getFileSource(fptResource) {
                                resources.append(source)
                            }
                            offset += parsedBytes
                            myself.progress(0, totalBytes, 0)
                        }
                        //                        switch parsedBytes {
                        //                        case 0:
                        //                            break
                        //                        case -1:
                        //                            let error = CFReadStreamGetError(stream)
                        //                            myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                        //                            myself.stop()
                        //                            return
                        //                        case 1..<CFIndex.max:
                        //                            let value = entity.pointee?.takeUnretainedValue()
                        //                            if let fptResource = value {
                        //                                resources?.append(fptResource)
                        //                            }
                        //                            offset += parsedBytes
                        //                            myself.progress(0, totalBytes, 0)
                        //                        default:
                        //                            print("")
                        //                        }
                    } while parsedBytes > 0
                    entity.deinitialize(count: 0)
                    myself.success(resources)
                    myself.stopRead()
                }
                else
                {
                    let error = CFReadStreamGetError(stream)
                    myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                    myself.stopRead()
                }
            case CFStreamEventType.endEncountered:
                myself.stopRead()
            case CFStreamEventType.errorOccurred:
                let error = CFReadStreamGetError(stream)
                myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                myself.stopRead()
            default:
                print("")
            }
        }, &streamClientContext)
        
        if !supportsAsynchronousNotification {
            return false
        }
        CFReadStreamScheduleWithRunLoop(readsStream, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes)
        return CFReadStreamOpen(readsStream)
    }
    
    func stopRead() {
        CFReadStreamUnscheduleFromRunLoop(self.readsStream, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes)
        CFReadStreamClose(self.readsStream)
        self.readData = NSMutableData()
        self.readsStream = nil
    }
}

// MARK: - Download
extension FTPRequest {
    public func download(loaclPath: String, success: @escaping (SuccessClosure), progress: @escaping (ProgressClosure), failer: @escaping(FailerClosure)) -> Bool {
        
        if !FileManager.default.fileExists(atPath: loaclPath) {
            FileManager.default.createFile(atPath: loaclPath, contents: nil, attributes: nil)
        }
        let url = URL(fileURLWithPath: loaclPath)
        self.writeStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, url as CFURL)
        CFWriteStreamSetProperty(writeStream, CFStreamPropertyKey.appendToFile, kCFBooleanTrue)
        if !CFWriteStreamOpen(writeStream) {
            return false
        }
        self.success = success
        self.progress = progress
        self.failer = failer
        var fileAttributes = try? FileManager.default.attributesOfItem(atPath: loaclPath)
        self.finishSize = fileAttributes?[FileAttributeKey.size] as! Int
        self.readsStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault, server as CFURL) as! CFReadStream
        
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPUserName), user as CFTypeRef)
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPPassword), pass as CFTypeRef)
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPFetchResourceInfo), true as CFTypeRef)
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPAttemptPersistentConnection), false as CFTypeRef)
        CFReadStreamSetProperty(readsStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPFileTransferOffset), finishSize as CFTypeRef)
        
        let registeredEvents: CFOptionFlags =
                CFStreamEventType.openCompleted.rawValue |
                CFStreamEventType.canAcceptBytes.rawValue |
                CFStreamEventType.hasBytesAvailable.rawValue |
                CFStreamEventType.errorOccurred.rawValue |
                CFStreamEventType.endEncountered.rawValue
        let supportsAsynchronousNotification = CFReadStreamSetClient(readsStream, registeredEvents, { (stream, event, data) in
            let myself = Unmanaged<FTPRequest>.fromOpaque(data!).takeUnretainedValue()
            switch event {
            case CFStreamEventType.openCompleted:
                let resourceSizeNumber: Int = CFReadStreamCopyProperty(stream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPResourceSize)) as! Int
                if resourceSizeNumber > 0 {
                    var resourceSize = 0
                    CFNumberGetValue(resourceSizeNumber as CFNumber, CFNumberType.longLongType, &resourceSize)
                    myself.totalSize = resourceSize
                }
                if myself.finishSize >= myself.totalSize {
                    myself.success(true)
                    myself.stopWrite()
                }
            case CFStreamEventType.hasBytesAvailable:
                let buffer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>(bitPattern: DownloadBufferSize)!
                let byteRead = CFReadStreamRead(stream, buffer, DownloadBufferSize)
                if byteRead > 0
                {
                    var offset = 0
                    repeat {
                        let byteWrite = CFWriteStreamWrite(myself.writeStream, buffer.advanced(by: offset), byteRead-offset)
                        if byteWrite > 0 {
                            offset += byteWrite
                            myself.finishSize += byteWrite
                            myself.progress(myself.totalSize, myself.finishSize, CGFloat(myself.finishSize)/CGFloat(myself.totalSize) * 100)
                        } else if byteWrite == 0 {
                            break
                        } else {
                            let error = CFReadStreamGetError(stream)
                            myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                            myself.stopRead()
                            return
                        }
                    } while (byteRead > offset)
                }
                else if byteRead == 0
                {
                    myself.success(true)
                    myself.stopWrite()
                }
                else
                {
                    let error = CFReadStreamGetError(stream)
                    myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                    myself.stopRead()
                }
            case CFStreamEventType.endEncountered:
                myself.success(true)
                myself.stopWrite()
            case CFStreamEventType.errorOccurred:
                let error = CFReadStreamGetError(stream)
                myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                myself.stopRead()
            default:
                print("")
            }
        }, &streamClientContext)
        
        if supportsAsynchronousNotification {
            CFReadStreamScheduleWithRunLoop(self.readsStream, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes);
            return CFReadStreamOpen(self.readsStream)
        } else {
            return false
        }
    }
    
    public func stopWrite() {
        CFReadStreamUnscheduleFromRunLoop(self.readsStream, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes)
        CFReadStreamClose(self.readsStream)
        self.readsStream = nil
        
        CFWriteStreamClose(self.writeStream)
        self.writeStream = nil
    }
}

// MARK: - Upload
extension FTPRequest {
    
    public func upload(localPath: String, success: @escaping (SuccessClosure), progress: @escaping (ProgressClosure), failer: @escaping(FailerClosure)) -> Bool {
        let url = URL(fileURLWithPath: localPath)
        var fileAttributes = try? FileManager.default.attributesOfItem(atPath: localPath)
        totalSize = fileAttributes?[FileAttributeKey.size] as! Int
        readsStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, url as CFURL)
        guard CFReadStreamOpen(readsStream), server != nil else { return false }
        self.success = success
        self.failer = failer
        writeStream = (CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, server as CFURL) as! CFWriteStream)
        CFWriteStreamSetProperty(writeStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPUserName), user as CFTypeRef)
        CFWriteStreamSetProperty(writeStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPPassword), pass as CFTypeRef)
        
        let registeredEvents: CFOptionFlags =
                CFStreamEventType.openCompleted.rawValue |
                CFStreamEventType.canAcceptBytes.rawValue |
                CFStreamEventType.hasBytesAvailable.rawValue |
                CFStreamEventType.errorOccurred.rawValue |
                CFStreamEventType.endEncountered.rawValue
        let supportsAsynchronousNotification = CFWriteStreamSetClient(writeStream, registeredEvents, { (stream, event, data) in
            let myself = Unmanaged<FTPRequest>.fromOpaque(data!).takeUnretainedValue()
            switch event {
            case CFStreamEventType.canAcceptBytes:
                let buffer: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>(bitPattern: UploadBufferSize)!
                let byteRead = CFWriteStreamWrite(stream, buffer, UploadBufferSize)
                if byteRead > 0
                {
                    var offset = 0
                    repeat {
                        let byteWrite = CFWriteStreamWrite(myself.writeStream, buffer.advanced(by: offset), byteRead-offset)
                        if byteWrite > 0
                        {
                            offset += byteWrite
                            myself.finishSize += byteWrite
                            myself.progress(myself.totalSize, myself.finishSize, CGFloat(myself.finishSize)/CGFloat(myself.totalSize) * 100)
                        }
                        else if byteWrite == 0
                        {
                            break
                        }
                        else
                        {
                            let error = CFWriteStreamGetError(stream)
                            myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                            myself.stopRead()
                            return
                        }
                    } while (byteRead > offset)
                }
                else if byteRead == 0
                {
                    myself.success(true)
                    myself.stopWrite()
                }
                else
                {
                    let error = CFWriteStreamGetError(stream)
                    myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                    myself.stopUpload()
                }
            case CFStreamEventType.endEncountered:
                myself.success(true)
                myself.stopUpload()
            case CFStreamEventType.errorOccurred:
                let error = CFWriteStreamGetError(stream)
                myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                myself.stopUpload()
            default:
                print("")
            }
        }, &streamClientContext)
        
        if supportsAsynchronousNotification {
            CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes);
            return CFWriteStreamOpen(writeStream)
        } else {
            return false
        }
    }
    
    public func stopUpload() {
        CFWriteStreamUnscheduleFromRunLoop(writeStream, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes)
        CFReadStreamClose(self.readsStream)
        self.readsStream = nil
        
        CFWriteStreamClose(self.writeStream)
        self.writeStream = nil
    }
}

// MARK: - Create
extension FTPRequest {
    
    public func create(success: @escaping (SuccessClosure), failer: @escaping(FailerClosure)) -> Bool {
        writeStream = (CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, server as CFURL) as! CFWriteStream)
        CFWriteStreamSetProperty(writeStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPUserName), user as CFTypeRef)
        CFWriteStreamSetProperty(writeStream, CFStreamPropertyKey(rawValue: kCFStreamPropertyFTPPassword), pass as CFTypeRef)
        
        let registeredEvents: CFOptionFlags =
                CFStreamEventType.openCompleted.rawValue |
                CFStreamEventType.canAcceptBytes.rawValue |
                CFStreamEventType.hasBytesAvailable.rawValue |
                CFStreamEventType.errorOccurred.rawValue |
                CFStreamEventType.endEncountered.rawValue
        let supportsAsynchronousNotification = CFWriteStreamSetClient(writeStream, registeredEvents, { (stream, event, data) in
            let myself = Unmanaged<FTPRequest>.fromOpaque(data!).takeUnretainedValue()
            switch event {
            case CFStreamEventType.hasBytesAvailable, CFStreamEventType.endEncountered:
                myself.success(true)
                myself.stopCreate()
            case CFStreamEventType.errorOccurred:
                let error = CFWriteStreamGetError(stream)
                myself.failer(CFStreamErrorDomain(rawValue: error.domain)!, Int(error.error), myself.getErrorDescription(code: Int(error.error)))
                myself.stopCreate()
            default:
                print("")
            }
        }, &streamClientContext)
        if supportsAsynchronousNotification {
            CFWriteStreamScheduleWithRunLoop(self.writeStream, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes)
            return CFWriteStreamOpen(self.writeStream)
        } else {
            return false
        }
    }
    
    public func stopCreate() {
        CFWriteStreamUnscheduleFromRunLoop(self.writeStream, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes);
        CFWriteStreamClose(self.writeStream);
        self.writeStream = nil;
    }
}


func bridge<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func bridge<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

func bridgeRetained<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
}

func bridgeTransfer<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}




