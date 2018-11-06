/* This program is free software. It comes without any warranty, to
     * the extent permitted by applicable law. You can redistribute it
     * and/or modify it under the terms of the Do What The Fuck You Want
     * To Public License, Version 2, as published by Sam Hocevar. See
     * http://www.wtfpl.net/ for more details. */
package ua.rostopira.flutternearbymessages

import android.app.Activity
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.messages.Message
import com.google.android.gms.nearby.messages.MessageListener
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.lang.ref.WeakReference
import java.nio.charset.Charset

class FlutterNearbyMessagesPlugin: MessageListener(), MethodCallHandler {
    private var activity: WeakReference<Activity>? = null
    private val msgs = mutableSetOf<Message>()

    override fun onMethodCall(call: MethodCall, result: Result) {
        val act = activity?.get()
        if (act == null) {
            result.error("0", "Activity is null", null)
            return
        }
        if (call.method == "apikey") {
            result.success(null);
            return
        }
        val client = Nearby.getMessagesClient(act)
        when(call.method) {
            "subscribe" ->
                client.subscribe(this).addOnFailureListener {
                    result.error("-2", it.message, null)
                }.addOnSuccessListener {
                    result.success(null)
                }
            "unsubscribe" -> {
                client.unsubscribe(this)
                result.success(null)
            }
            "publish" -> {
                val msg = Message((call.arguments() as String).toByteArray())
                msgs.add(msg)
                client.publish(msg).addOnFailureListener {
                    result.error("-2", it.message, null)
                    msgs.remove(msg)
                }.addOnSuccessListener {
                    result.success(null)
                }
            }
            "unpublish" -> {
                msgs.forEach { client.unpublish(it) }
                msgs.clear()
                result.success(null)
            }
            else -> {
                result.error("-1", "No implementation found for method \"${call.method}\"", null)
                return
            }
        }
    }

    override fun onFound(msg: Message) {
        channel.invokeMethod("found", msg.content.toString(Charset.defaultCharset()))
    }

    override fun onLost(msg: Message) {
        channel.invokeMethod("lost", msg.content.toString(Charset.defaultCharset()))
    }

    companion object {
        lateinit var channel: MethodChannel
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val inst = FlutterNearbyMessagesPlugin()
            inst.activity = WeakReference(registrar.activity())
            channel = MethodChannel(registrar.messenger(), "flutter_nearby_messages")
            channel.setMethodCallHandler(inst)
        }
    }
}
