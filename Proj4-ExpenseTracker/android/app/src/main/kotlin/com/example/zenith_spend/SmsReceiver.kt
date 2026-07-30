package com.example.zenith_spend

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.telephony.SmsMessage
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent.extras
            if (bundle != null) {
                try {
                    val pdus = bundle.get("pdus") as Array<*>?
                    if (pdus != null) {
                        val format = bundle.getString("format")
                        for (pdu in pdus) {
                            val sms = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                SmsMessage.createFromPdu(pdu as ByteArray, format)
                            } else {
                                SmsMessage.createFromPdu(pdu as ByteArray)
                            }
                            val sender = sms.displayOriginatingAddress
                            val messageBody = sms.messageBody
                            Log.d("ZenithSmsReceiver", "SMS from $sender: $messageBody")
                        }
                    }
                } catch (e: Exception) {
                    Log.e("ZenithSmsReceiver", "Error parsing SMS", e)
                }
            }
        }
    }
}
