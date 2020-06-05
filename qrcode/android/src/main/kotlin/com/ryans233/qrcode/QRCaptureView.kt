package com.ryans233.qrcode

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Bundle
import android.view.View
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.zxing.ResultPoint
import com.journeyapps.barcodescanner.BarcodeCallback
import com.journeyapps.barcodescanner.BarcodeResult
import com.journeyapps.barcodescanner.BarcodeView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.platform.PlatformView

class QRCaptureView(private val registrar: PluginRegistry.Registrar, id: Int) :
        PlatformView, MethodCallHandler {
    companion object {
        const val CAMERA_REQUEST_ID = 513469796
    }

    var barcodeView: BarcodeView? = null
    val channel: MethodChannel

    init {
        registrar.addRequestPermissionsResultListener(CameraRequestPermissionsListener())
        channel = MethodChannel(registrar.messenger(), "plugins/qr_capture/method_$id")
        channel.setMethodCallHandler(this)
        barcodeView = BarcodeView(registrar.activity())
        if (checkPermission()) initBarcodeView()
        else requestCameraPermission()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "resume" -> resume()
            "pause" -> pause()
            "setTorchMode" -> setTorchMode(call.arguments as Boolean)
            "requestCameraPermission" -> requestCameraPermission()
        }
    }

    private fun setTorchMode(enabled: Boolean) {
        barcodeView?.setTorch(enabled)
    }

    private fun resume() {
        barcodeView?.resume()
    }

    private fun pause() {
        barcodeView?.pause()
    }

    private fun requestCameraPermission() {
        ActivityCompat.requestPermissions(registrar.activity(),
                arrayOf(Manifest.permission.CAMERA),
                CAMERA_REQUEST_ID)
    }

    private fun initBarcodeView() {
        barcodeView?.decodeContinuous(
                object : BarcodeCallback {
                    override fun barcodeResult(result: BarcodeResult) {
                        channel.invokeMethod("onCaptured", result.text)
                    }

                    override fun possibleResultPoints(resultPoints: List<ResultPoint>) {}
                }
        )

        barcodeView?.resume()

        registrar.activity().application.registerActivityLifecycleCallbacks(
                object : Application.ActivityLifecycleCallbacks {
                    override fun onActivityPaused(p0: Activity?) {
                        if (p0 == registrar.activity()) {
                            barcodeView?.pause()
                        }
                    }

                    override fun onActivityResumed(p0: Activity?) {
                        if (p0 == registrar.activity()) {
                            barcodeView?.resume()
                        }
                    }

                    override fun onActivityStarted(p0: Activity?) {
                    }

                    override fun onActivityDestroyed(p0: Activity?) {
                    }

                    override fun onActivitySaveInstanceState(p0: Activity?, p1: Bundle?) {
                    }

                    override fun onActivityStopped(p0: Activity?) {
                    }

                    override fun onActivityCreated(p0: Activity?, p1: Bundle?) {
                    }

                }
        )
    }

    private fun checkPermission(): Boolean {
        return (ContextCompat.checkSelfPermission(registrar.activeContext(),
                Manifest.permission.CAMERA)
                == PERMISSION_GRANTED)
    }

    override fun getView(): View {
        return this.barcodeView!!
    }

    override fun dispose() {
        barcodeView?.pause()
        barcodeView = null
    }

    private inner class CameraRequestPermissionsListener : PluginRegistry.RequestPermissionsResultListener {
        override fun onRequestPermissionsResult(id: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
            return if (id == CAMERA_REQUEST_ID) {
                val result = grantResults[0] == PERMISSION_GRANTED
                channel.invokeMethod("onPermissionRequested", result)
                if (result) initBarcodeView()
                result
            } else
                false
        }
    }
}
