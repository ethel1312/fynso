package app.fynso.fynso;

import androidx.annotation.NonNull;

import java.util.TimeZone;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.fynso/timezone";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if ("getTimeZoneName".equals(call.method)) {
                        try {
                            String id = TimeZone.getDefault().getID(); // p.ej. "America/Lima"
                            if (id == null || id.trim().isEmpty()) {
                                result.success("UTC");
                            } else {
                                result.success(id);
                            }
                        } catch (Exception e) {
                            result.success("UTC");
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }
}
