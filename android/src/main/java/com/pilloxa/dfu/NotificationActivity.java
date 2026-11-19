package com.pilloxa.dfu;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;

/**
 * Target of the DFU notification. See {@link DfuService#getNotificationTarget()}.
 */
public class NotificationActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // If this activity is the root activity of the task, the app is not running
        if (isTaskRoot()) {
            // Start the app before finishing. The launch intent comes from the
            // package manager, so no React instance is needed (there is none
            // yet when the app was closed during the upload).
            final Intent intent = getPackageManager().getLaunchIntentForPackage(getPackageName());
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                final Bundle extras = getIntent().getExtras();
                if (extras != null) {
                    intent.putExtras(extras); // copy all extras
                }
                startActivity(intent);
            }
        }

        // Now finish, which will drop you to the activity at which you were at the top of the task stack
        finish();
    }
}
