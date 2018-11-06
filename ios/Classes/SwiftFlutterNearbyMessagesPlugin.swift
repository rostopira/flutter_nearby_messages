/* This program is free software. It comes without any warranty, to
     * the extent permitted by applicable law. You can redistribute it
     * and/or modify it under the terms of the Do What The Fuck You Want
     * To Public License, Version 2, as published by Sam Hocevar. See
     * http://www.wtfpl.net/ for more details. */
import Flutter
import UIKit
import NearbyMessages

@objc public class SwiftFlutterNearbyMessagesPlugin: NSObject, FlutterPlugin {
    private var client: GNSMessageManager? = nil
    private var channel: FlutterMethodChannel!
    private var subscription: GNSSubscription? = nil
    private var publications = [GNSPublication]()
    
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_nearby_messages", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterNearbyMessagesPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "apikey" {
            if  let key = call.arguments as? String,
                let mm = try? GNSMessageManager(apiKey: key)
            {
                client = mm
                result(nil)
            } else {
                result(FlutterError(code: "BAD_ARGS", message: "Wrong argument", details: nil))
            }
            return
        }
        guard let client = client else {
            result(FlutterError(code: "WTF", message: "Api key isn't set", details: nil))
            return
        }
        switch call.method {
        case "subscribe":
            subscription = client.subscription(messageFoundHandler: { (msg: GNSMessage?) in
                if let msg = msg {
                    self.channel.invokeMethod("found", arguments: String(data: msg.content, encoding: .utf8))
                }
            }, messageLostHandler: { (msg: GNSMessage?) in
                if let msg = msg {
                    self.channel.invokeMethod("lost", arguments: String(data: msg.content, encoding: .utf8))
                }
            }, paramsBlock: { params in
                params?.strategy = GNSStrategy(paramsBlock: { strategyParams in
                    strategyParams?.allowInBackground = false
                    strategyParams?.discoveryMediums = .audio
                    strategyParams?.discoveryMode = .scan
                })
            })
            result(nil)
        case "unsubscribe":
            subscription = nil
            result(nil)
        case "publish":
            if let msg = call.arguments as? String {
                let message = GNSMessage(content: msg.data(using: .utf8))
                if let publication = client.publication(with: message, paramsBlock: { params in
                    params?.strategy = GNSStrategy(paramsBlock: { strategyParams in
                        strategyParams?.allowInBackground = false
                        strategyParams?.discoveryMediums = .audio
                        strategyParams?.discoveryMode = .scan
                    })
                }) {
                    publications.append(publication)
                }
                result(nil)
            } else {
                result(FlutterError(code: "BAD_ARGS", message: "Arguments must be String", details: nil))
            }
        case "unpublish":
            publications.removeAll()
            result(nil)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
