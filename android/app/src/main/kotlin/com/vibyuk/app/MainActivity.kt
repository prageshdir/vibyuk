package com.vibyuk.app

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterFragmentActivity() {
    // FlutterFragmentActivity is used (instead of FlutterActivity) to support
    // biometric authentication dialogs and Razorpay bottom sheets, which
    // require a FragmentManager.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
