// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


// -----------------------------------------------------------------------------
///
/// This header file describes the constructs used to represent URL
/// load requests in a manner independent of protocol and URL scheme.
/// Immutable and mutable variants of this URL load request concept
/// are described, named `NSURLRequest` and `NSMutableURLRequest`,
/// respectively. A collection of constants is also declared to
/// exercise control over URL content caching policy.
///
/// `NSURLRequest` and `NSMutableURLRequest` are designed to be
/// customized to support protocol-specific requests. Protocol
/// implementors who need to extend the capabilities of `NSURLRequest`
/// and `NSMutableURLRequest` are encouraged to provide categories on
/// these classes as appropriate to support protocol-specific data. To
/// store and retrieve data, category methods can use the
/// `propertyForKey(_:,inRequest:)` and
/// `setProperty(_:,forKey:,inRequest:)` class methods on
/// `NSURLProtocol`. See the `NSHTTPURLRequest` on `NSURLRequest` and
/// `NSMutableHTTPURLRequest` on `NSMutableURLRequest` for examples of
/// such extensions.
///
/// The main advantage of this design is that a client of the URL
/// loading library can implement request policies in a standard way
/// without type checking of requests or protocol checks on URLs. Any
/// protocol-specific details that have been set on a URL request will
/// be used if they apply to the particular URL being loaded, and will
/// be ignored if they do not apply.
///
// -----------------------------------------------------------------------------

/// A cache policy
///
/// The `NSURLRequestCachePolicy` `enum` defines constants that
/// can be used to specify the type of interactions that take place with
/// the caching system when the URL loading system processes a request.
/// Specifically, these constants cover interactions that have to do
/// with whether already-existing cache data is returned to satisfy a
/// URL load request.
public enum NSURLRequestCachePolicy : UInt {
    /// Specifies that the caching logic defined in the protocol
    /// implementation, if any, is used for a particular URL load request. This
    /// is the default policy for URL load requests.
    case useProtocolCachePolicy
    /// Specifies that the data for the URL load should be loaded from the
    /// origin source. No existing local cache data, regardless of its freshness
    /// or validity, should be used to satisfy a URL load request.
    case reloadIgnoringLocalCacheData
    /// Specifies that not only should the local cache data be ignored, but that
    /// proxies and other intermediates should be instructed to disregard their
    /// caches so far as the protocol allows.  Unimplemented.
    case reloadIgnoringLocalAndRemoteCacheData // Unimplemented
    /// Older name for `NSURLRequestReloadIgnoringLocalCacheData`.
    public static var reloadIgnoringCacheData: NSURLRequestCachePolicy { return .reloadIgnoringLocalCacheData }
    /// Specifies that the existing cache data should be used to satisfy a URL
    /// load request, regardless of its age or expiration date. However, if
    /// there is no existing data in the cache corresponding to a URL load
    /// request, the URL is loaded from the origin source.
    case returnCacheDataElseLoad
    /// Specifies that the existing cache data should be used to satisfy a URL
    /// load request, regardless of its age or expiration date. However, if
    /// there is no existing data in the cache corresponding to a URL load
    /// request, no attempt is made to load the URL from the origin source, and
    /// the load is considered to have failed. This constant specifies a
    /// behavior that is similar to an "offline" mode.
    case returnCacheDataDontLoad
    /// Specifies that the existing cache data may be used provided the origin
    /// source confirms its validity, otherwise the URL is loaded from the
    /// origin source.
    /// - Note: Unimplemented.
    case reloadRevalidatingCacheData // Unimplemented
}

/// Network service type for an NSURLRequest
///
/// The `NSURLRequestNetworkServiceType` enum defines constants that
/// can be used to specify the service type to associate with this request. The
/// service type is used to provide the networking layers a hint of the purpose
/// of the request.
public enum NSURLRequestNetworkServiceType : UInt {
    /// Is the default value for an `NSURLRequest` when created.
    /// This value should be left unchanged for the vast majority of requests.
    case networkServiceTypeDefault
    /// Specifies that the request is for voice over IP control traffic.
    case networkServiceTypeVoIP
    /// Specifies that the request is for video traffic.
    case networkServiceTypeVideo
    /// Specifies that the request is for background traffic (such as a file download).
    case networkServiceTypeBackground
    /// Specifies that the request is for voice data.
    case networkServiceTypeVoice
}

/// An `NSURLRequest` object represents a URL load request in a
/// manner independent of protocol and URL scheme.
///
/// `NSURLRequest` encapsulates basic data elements about a URL load request.
///
/// In addition, `NSURLRequest` is designed to be extended to support
/// protocol-specific data by adding categories to access a property
/// object provided in an interface targeted at protocol implementors.
///
/// Protocol implementors should direct their attention to the
/// `NSURLRequestExtensibility` category on `NSURLRequest` for more
/// information on how to provide extensions on `NSURLRequest` to
/// support protocol-specific request information.
///
/// Clients of this API who wish to create `NSURLRequest` objects to
/// load URL content should consult the protocol-specific `NSURLRequest`
/// categories that are available. The `NSHTTPURLRequest` category on
/// `NSURLRequest` is an example.
///
/// Objects of this class are used with the `NSURLSession` API to perform the
/// load of a URL.
public class NSURLRequest : NSObject, NSSecureCoding, NSCopying, NSMutableCopying {
    
    public override func copy() -> AnyObject {
        return copyWithZone(nil)
    }
    
    public func copyWithZone(_ zone: NSZone) -> AnyObject {
        if self.dynamicType === NSURLRequest.self {
            // Already immutable
            return self
        }
        let c = NSURLRequest()
        c.setValues(from: self)
        return c
    }
    
    private func setValues(from source: NSURLRequest) {
        self.allHTTPHeaderFields = source.allHTTPHeaderFields
        self.url = source.url
        self.mainDocumentURL = source.mainDocumentURL
        self.httpMethod = source.httpMethod
    }
    
    public override func mutableCopy() -> AnyObject {
        return mutableCopyWithZone(nil)
    }
    
    public func mutableCopyWithZone(_ zone: NSZone) -> AnyObject {
        let c = NSMutableURLRequest()
        c.setValues(from: self)
        return c
    }
    
    public required init?(coder aDecoder: NSCoder) {
        NSUnimplemented()
    }
    
    public func encodeWithCoder(_ aCoder: NSCoder) {
        NSUnimplemented()
    }
    
    private override init() {}
    
    /// Indicates that NSURLRequest implements the NSSecureCoding protocol.
    public static func supportsSecureCoding() -> Bool { return true }
    
    /// Initializes an NSURLRequest with the given URL.
    ///
    /// - Parameter URL: The URL for the request.
    public convenience init(url: NSURL) {
        self.init()
        self.url = url
    }
    
    /// The URL of the receiver.
    /*@NSCopying */public private(set) var url: NSURL?
    
    /// The main document URL associated with this load.
    ///
    /// This URL is used for the cookie "same domain as main
    /// document" policy. There may also be other future uses.
    /*@NSCopying*/ public private(set) var mainDocumentURL: NSURL?
    
    /// Returns the HTTP request method of the receiver.
    public private(set) var httpMethod: String? = "GET"
    
    /// A dictionary containing all the HTTP header fields
    /// of the receiver.
    public private(set) var allHTTPHeaderFields: [String: String]?
    
    /// Returns the value which corresponds to the given header field.
    ///
    /// Note that, in keeping with the HTTP RFC, HTTP header field
    /// names are case-insensitive.
    /// - Parameter field: the header field name to use for the lookup
    ///     (case-insensitive).
    /// - Returns: the value associated with the given header field, or `nil` if
    /// there is no value associated with the given header field.
    public func value(forHTTPHeaderField field: String) -> String? {
        guard let f = allHTTPHeaderFields else { return nil }
        return existingHeaderField(field, inHeaderFields: f)?.1
    }
}

/// An `NSMutableURLRequest` object represents a mutable URL load
/// request in a manner independent of protocol and URL scheme.
///
/// This specialization of `NSURLRequest` is provided to aid
/// developers who may find it more convenient to mutate a single request
/// object for a series of URL loads instead of creating an immutable
/// `NSURLRequest` for each load. This programming model is supported by
/// the following contract stipulation between `NSMutableURLRequest` and the
/// `NSURLSession` API: `NSURLSession` makes a deep copy of each
/// `NSMutableURLRequest` object passed to it.
///
/// `NSMutableURLRequest` is designed to be extended to support
/// protocol-specific data by adding categories to access a property
/// object provided in an interface targeted at protocol implementors.
///
/// Protocol implementors should direct their attention to the
/// `NSMutableURLRequestExtensibility` category on
/// `NSMutableURLRequest` for more information on how to provide
/// extensions on `NSMutableURLRequest` to support protocol-specific
/// request information.
///
/// Clients of this API who wish to create `NSMutableURLRequest`
/// objects to load URL content should consult the protocol-specific
/// `NSMutableURLRequest` categories that are available. The
/// `NSMutableHTTPURLRequest` category on `NSMutableURLRequest` is an
/// example.
public class NSMutableURLRequest : NSURLRequest {
    public required init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    private override init() { super.init() }
    
    /*@NSCopying */ public override var url: NSURL? {
        get { return super.url }
        //TODO: set { super.URL = newValue.map{ $0.copy() as! NSURL } }
        set { super.url = newValue }
    }
    
    /// The main document URL.
    ///
    /// The caller should pass the URL for an appropriate main
    /// document, if known. For example, when loading a web page, the URL
    /// of the main html document for the top-level frame should be
    /// passed.  This main document will be used to implement the cookie
    /// *only from same domain as main document* policy, and possibly
    /// other things in the future.
    /*@NSCopying*/ public override var mainDocumentURL: NSURL? {
        get { return super.mainDocumentURL }
        //TODO: set { super.mainDocumentURL = newValue.map{ $0.copy() as! NSURL } }
        set { super.mainDocumentURL = newValue }
    }
    
    
    /// The HTTP request method of the receiver.
    public override var httpMethod: String? {
        get { return super.httpMethod }
        set { super.httpMethod = newValue }
    }
    
    /// Sets the value of the given HTTP header field.
    ///
    /// If a value was previously set for the given header
    /// field, that value is replaced with the given value. Note that, in
    /// keeping with the HTTP RFC, HTTP header field names are
    /// case-insensitive.
    /// - Parameter value: the header field value.
    /// - Parameter field: the header field name (case-insensitive).
    public func setValue(_ value: String?, forHTTPHeaderField field: String) {
        var f: [String: String] = allHTTPHeaderFields ?? [:]
        if let old = existingHeaderField(field, inHeaderFields: f) {
            f.removeValue(forKey: old.0)
        }
        f[field] = value
        allHTTPHeaderFields = f
    }
    
    /// Adds an HTTP header field in the current header dictionary.
    ///
    /// This method provides a way to add values to header
    /// fields incrementally. If a value was previously set for the given
    /// header field, the given value is appended to the previously-existing
    /// value. The appropriate field delimiter, a comma in the case of HTTP,
    /// is added by the implementation, and should not be added to the given
    /// value by the caller. Note that, in keeping with the HTTP RFC, HTTP
    /// header field names are case-insensitive.
    /// - Parameter value: the header field value.
    /// - Parameter field: the header field name (case-insensitive).
    public func addValue(_ value: String, forHTTPHeaderField field: String) {
        var f: [String: String] = allHTTPHeaderFields ?? [:]
        if let old = existingHeaderField(field, inHeaderFields: f) {
            f[old.0] = old.1 + "," + value
        } else {
            f[field] = value
        }
        allHTTPHeaderFields = f
    }
}

/// Returns an existing key-value pair inside the header fields if it exists.
private func existingHeaderField(_ key: String, inHeaderFields fields: [String: String]) -> (String, String)? {
    for (k, v) in fields {
        if k.lowercased() == key.lowercased() {
            return (k, v)
        }
    }
    return nil
}
