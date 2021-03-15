package com.example.swiftlauncher;

import android.annotation.SuppressLint;
import android.app.WallpaperManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.hardware.display.DisplayManager;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.app.SearchManager;

import org.json.JSONArray;
import org.json.JSONException;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.net.Uri;
import android.graphics.Bitmap;
import android.view.Display;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "launcher_assist";
    MethodChannel.Result appChangeResult;
    public static final String STREAM = "screen_status";
    EventChannel.EventSink mEvents;

    public static final String STREAM_RESUME = "updatedApps";
    EventChannel.EventSink appsStream;
//    @Override
//    protected void onResume() {
//        super.onResume();
//        overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
//    }

    BroadcastReceiver onAppListChangedReciever = new BroadcastReceiver() {
        @Override
        public void onReceive(Context c, Intent intent) {
            try {
                final String action = intent.getAction();

                if (action != null) {
                    Uri data = intent.getData();
                    String pkgName = data.getEncodedSchemeSpecificPart();
                    if (appsStream != null) {
                        if (intent.getAction().equals(Intent.ACTION_PACKAGE_REMOVED)) {
                            appsStream.success('R' + pkgName);
                        } else if (intent.getAction().equals(Intent.ACTION_PACKAGE_ADDED)) {
                            appsStream.success('A' + pkgName);
                        }
                    }
                }
            } catch (Exception e) {
            }
        }
    };

    BroadcastReceiver receiverScreenStatus = new BroadcastReceiver() {
        @Override
        public void onReceive(Context c, Intent intent) {
            try {
                final String action = intent.getAction();
                if (action != null) {
                    if (mEvents != null) {
                        if (intent.getAction().equals(Intent.ACTION_SCREEN_OFF)) {
                            mEvents.success(true);
                        }
//                        else if (intent.getAction().equals(Intent.ACTION_SCREEN_ON)) {
//                            mEvents.success(true);
//                        }
                    }
                }
            } catch (Exception e) {
            }
        }
    };

    @Override
    protected void onStop() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
//            if (!isScreenOn() && mEvents != null) {
//                mEvents.success(true);
//            }
//        }
        super.onStop();
    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT_WATCH)
    private boolean isScreenOn() {
        DisplayManager dm = (DisplayManager)
                getApplicationContext().getSystemService(Context.DISPLAY_SERVICE);
        for (Display display : dm.getDisplays()) {
            if (display.getState() != Display.STATE_OFF) {
                return true;
            }
        }
        return false;
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new EventChannel(flutterEngine.getDartExecutor(), STREAM).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object args, final EventChannel.EventSink events) {
                        mEvents = events;
                    }

                    @Override
                    public void onCancel(Object args) {
                    }
                }
        );
        new EventChannel(flutterEngine.getDartExecutor(), STREAM_RESUME).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object args, final EventChannel.EventSink events) {
                        appsStream = events;
                    }

                    @Override
                    public void onCancel(Object args) {
                    }
                }
        );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getAllApps")) {
                                getAllApps(result);
                            } else if (call.method.equals("launchApp")) {
                                launchApp(call.argument("packageName").toString());
                            } else if (call.method.equals("getWallpaper")) {
                                getWallpaper(result);
                            } else if (call.method.equals("searchGoogle")) {
                                searchGoogle(call.argument("query").toString());
                            } else if (call.method.equals("searchPlaystore")) {
                                searchPlaystore(call.argument("query").toString());
                            } else if (call.method.equals("searchYoutube")) {
                                searchYoutube(call.argument("query").toString());
                            } else if (call.method.equals("searchVanced")) {
                                searchVanced(call.argument("query").toString());
                            } else if (call.method.equals("openSetting")) {
                                openSetting(call.argument("package").toString());
                            } else if (call.method.equals("getIconPacks")) {
                                getIconPacks(result);
                            } else if (call.method.equals("getIcon")) {
                                getIconFromPack(result, call.argument("pckg").toString(), call.argument("key").toString());
                            } else if (call.method.equals("expand")) {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N)
                                    expandNotif();
                            } else if (call.method.equals("appChangeResult")) {
                                if (appChangeResult == null) {
                                    appChangeResult = result;
                                }
                            } else if (call.method.equals("getAppInfo")) {
                                getAppInfo(result, call.argument("package").toString());
                            } else if (call.method.equals("uninstallApp")) {
                                uninstallApp(call.argument("package").toString());
                            } else if (call.method.equals("wallpaper")) {
//                                setWallpaper(call.argument("i").toString(), call.argument("path").toString(), result);
                                wallpaperResult = result;
                                pickImage(call.argument("i").toString(),"");
                            }

                        }
                );
    }

    String wallpaperChoice;
    MethodChannel.Result wallpaperResult;

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 3333 && resultCode == RESULT_OK && data.getData() != null) {
            Uri selectedImage = data.getData();
            String[] filePathColumn = {MediaStore.MediaColumns.DATA};

            // Get the cursor
            Cursor cursor = getContentResolver().query(selectedImage,
                    filePathColumn, null, null, null);
            // Move to first row
            if (cursor != null){
                cursor.moveToFirst();

                int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
                String imgpath = cursor.getString(columnIndex);
                cursor.close();
                setWallpaper(wallpaperChoice,imgpath);
            }

        }
    }

    private void pickImage(String i, String path) {
        wallpaperChoice = i;
        Intent galleryIntent = new Intent(Intent.ACTION_PICK,
                android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(galleryIntent, 3333);
    }

    private void setWallpaper(String i, String path) {
        String id = i;
        WallpaperManager wallpaperManager = WallpaperManager.getInstance(getApplicationContext());
        String res = "";
          File file = new File(path);
//        File file = new File(getApplicationContext().getExternalFilesDir(null), path);

        //File file = new File(Activity.ge);
        //Activity.getDir("flutter", 0).getPath()
        // set bitmap to wallpaper
        Bitmap bitmap = BitmapFactory.decodeFile(file.getAbsolutePath());
        if (id.equals("1")) {
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM);
                    res = "Home Screen Set Successfully";
                } else {
                    res = "To Set Home Screen Requires Api Level 24";
                }


            } catch (IOException ex) {
                ex.printStackTrace();
            }finally {
                wallpaperResult.success("result");
            }
        } else if (id.equals("2")) try {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK);
                res = "Lock Screen Set Successfully";
            } else {
                res = "To Set Lock Screen Requires Api Level 24";
            }


        } catch (IOException e) {
            res = e.toString();
            e.printStackTrace();
        }finally {
            wallpaperResult.success(res);
//            wallpaperResult.success("result");
        }

//        else if (id == 3) {
//            try {
//                wallpaperManager.setBitmap(bitmap);
//                res = "Home And Lock Screen Set Successfully";
//            } catch (IOException e) {
//                res = e.toString();
//                e.printStackTrace();
//            }
//
//        }
//        else if(id==4){
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                if (activity.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
//                        != PackageManager.PERMISSION_GRANTED&&
//                        activity.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
//                                != PackageManager.PERMISSION_GRANTED) {
//                    activity.requestPermissions(new String[]{Manifest.permission.READ_EXTERNAL_STORAGE,Manifest.permission.WRITE_EXTERNAL_STORAGE},1);
//                }
//                else {
//                    Uri uri = Uri.fromFile(file);
//                    Uri contentURI = getImageContentUri(getActiveContext(), file);
//
//                    Intent intent = new Intent(wallpaperManager.getCropAndSetWallpaperIntent(contentURI));
//                    String mime = "image/*";
//                    if (intent != null) {
//                        intent.setDataAndType(contentURI, mime);
//                    }
//                    try {
//                        mRegistrar.activity().startActivityForResult(intent,2);
//                    } catch (ActivityNotFoundException e) {
//                        //handle error
//                        res = "Error To Set Wallpaer";
//                    }
//                }
//            }
//        }

//        return res;
    }


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        IntentFilter filter = new IntentFilter(Intent.ACTION_PACKAGE_ADDED);
        filter.addAction(Intent.ACTION_PACKAGE_REMOVED);
        filter.addAction(Intent.ACTION_PACKAGE_CHANGED);
        filter.addDataScheme("package");
        getApplicationContext().registerReceiver(onAppListChangedReciever, filter);

        IntentFilter screenFilter = new IntentFilter(Intent.ACTION_SCREEN_ON);
        screenFilter.addAction(Intent.ACTION_SCREEN_OFF);
        getApplicationContext().registerReceiver(receiverScreenStatus, screenFilter);
    }

    public void onReceive(Context context, Intent intent) {
        final String action = intent.getAction();

        if (action.equals(Intent.ACTION_PACKAGE_ADDED)) {
            Uri data = intent.getData();
            String pkgName = data.getEncodedSchemeSpecificPart();
        }

        /* etc. */
    }


    @RequiresApi(api = Build.VERSION_CODES.M)
    private void expandNotif() {
        try {
            @SuppressLint("WrongConstant") Object sbservice = getSystemService("statusbar");
            Class<?> statusbarManager = Class.forName("android.app.StatusBarManager");
            Method showsb = statusbarManager.getMethod("expandNotificationsPanel");
            showsb.invoke(sbservice);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        }
    }

    //TODO GET ICON FROM PACK THAT IS GIVEN
    private void getIconFromPack(MethodChannel.Result result, String packageName, String key) {
//        List<String> keys = Arrays.asList(key.split(","));
//        ArrayList<byte[]> toReturn = new ArrayList<>();
//        for (String mKey : keys) {
//            IconPackManager manager = new IconPackManager();
//            manager.setContext(getApplication());
//            HashMap<String, IconPackManager.IconPack> map = manager.getAvailableIconPacks(false);
//            IconPackManager.IconPack pack = map.get(packageName);
//            pack.load();
//            Bitmap bitmap = pack.getIconForPackage(mKey, null);
//            if (bitmap == null) {
//                toReturn.add(null);
//            } else {
//                toReturn.add(convertToBytes(bitmap, Bitmap.CompressFormat.PNG, 100));
//            }
//        }
//
//        result.success(toReturn);

        new AsyncTask() {
            MethodChannel.Result mResult;
            ArrayList<byte[]> toReturn;

            @Override
            protected Object doInBackground(Object[] objects) {
                mResult = (Result) objects[0];

                String packageName = (String) objects[1];
                String key = (String) objects[2];


                List<String> keys = Arrays.asList(key.split(","));
                toReturn = new ArrayList<>();
                for (String mKey : keys) {
                    IconPackManager manager = new IconPackManager();
                    manager.setContext(getApplication());
                    HashMap<String, IconPackManager.IconPack> map = manager.getAvailableIconPacks(false);
                    IconPackManager.IconPack pack = map.get(packageName);
                    pack.load();
                    Bitmap bitmap = pack.getIconForPackage(mKey, null);
                    if (bitmap == null) {
                        toReturn.add(null);
                    } else {
                        toReturn.add(convertToBytes(bitmap, Bitmap.CompressFormat.PNG, 100));
                    }
                }

                return null;
            }

            @Override
            protected void onPostExecute(Object o) {
                super.onPostExecute(o);
                mResult.success(toReturn);
            }
        }.execute(result, packageName, key);
    }


//    private void getIconFromPack(MethodChannel.Result result, String packageName, String key) {
//        //Given list of packagenames, send list of bitmaps
//        IconPackManager manager = new IconPackManager();
//        manager.setContext(getApplication());
//        HashMap<String, IconPackManager.IconPack> map = manager.getAvailableIconPacks(false);
//        IconPackManager.IconPack pack = map.get(packageName);
//        pack.load();
//        Bitmap bitmap = pack.getIconForPackage(key, null);
//        if (bitmap == null) {
//            result.success(null);
//        } else {
//
//            result.success(convertToBytes(bitmap, Bitmap.CompressFormat.PNG, 100));
//        }
//    }

    private void getIconPacks(MethodChannel.Result result) {
        IconPackManager manager = new IconPackManager();
        manager.setContext(getApplication());
        HashMap<String, IconPackManager.IconPack> map = manager.getAvailableIconPacks(true);
        String toSend = "";
        for (String key : map.keySet()) {
            toSend += map.get(key).name + "," + map.get(key).packageName + "\n";
        }
        result.success(toSend);
    }


    private void openSetting(String packageName) {
        Intent intent = new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + packageName));
        startActivity(intent);
    }

    private void searchGoogle(String search) {
        final Intent intent = new Intent(Intent.ACTION_WEB_SEARCH);
        intent.setPackage("com.google.android.googlequicksearchbox");
        intent.putExtra(SearchManager.QUERY, search);
        startActivity(intent);
    }

    private void searchPlaystore(String query) {
        Intent goToMarket = new Intent(Intent.ACTION_VIEW).setData(Uri.parse("market://search?q=" + query));
        startActivity(goToMarket);
    }

    private void searchYoutube(String query) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setPackage("com.google.android.youtube");
        intent.setData(Uri.parse("https://www.youtube.com/results?search_query=" + query));
        startActivity(intent);
    }

    private void searchVanced(String query) {
        Intent intent = new Intent(Intent.ACTION_VIEW);
        intent.setPackage("com.vanced.android.youtube");
        intent.setData(Uri.parse("https://www.youtube.com/results?search_query=" + query));
        startActivity(intent);
    }

    private void uninstallApp(String pkg) {
        Intent intent = new Intent(Intent.ACTION_DELETE);
        intent.setData(Uri.parse("package:" + pkg));
        startActivity(intent);
    }

    private void getAppInfo(MethodChannel.Result result, String pkgName) {
        Intent intent = new Intent(Intent.ACTION_MAIN, null);
        intent.addCategory(Intent.CATEGORY_LAUNCHER);

        PackageManager manager = getApplicationContext().getPackageManager();
        try {
            ApplicationInfo app = manager.getApplicationInfo(
                    pkgName, PackageManager.GET_META_DATA);

            if (manager.getLaunchIntentForPackage(app.packageName) != null) {

                byte[] iconData = convertToBytes(getBitmapFromDrawable(app.loadIcon(manager)),
                        Bitmap.CompressFormat.PNG, 100);
                Map<String, Object> current = new HashMap<>();
                current.put("label", app.loadLabel(manager).toString());
                current.put("icon", iconData);
                current.put("package", app.packageName);
                result.success(current);

            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
    }

    private void getAllApps(MethodChannel.Result result) {

        new AsyncTask() {
            MethodChannel.Result mResult;
            List<Map<String, Object>> _output;

            @Override
            protected Object doInBackground(Object[] objects) {
                mResult = (Result) objects[0];
                Intent intent = new Intent(Intent.ACTION_MAIN, null);
                intent.addCategory(Intent.CATEGORY_LAUNCHER);

                PackageManager manager = getApplicationContext().getPackageManager();
                List<ResolveInfo> resList = manager.queryIntentActivities(intent, 0);

                _output = new ArrayList<>();

                for (ResolveInfo resInfo : resList) {
                    try {
                        ApplicationInfo app = manager.getApplicationInfo(
                                resInfo.activityInfo.packageName, PackageManager.GET_META_DATA);
                        if (manager.getLaunchIntentForPackage(app.packageName) != null) {

                            byte[] iconData = convertToBytes(getBitmapFromDrawable(app.loadIcon(manager)),
                                    Bitmap.CompressFormat.PNG, 100);

                            Map<String, Object> current = new HashMap<>();
                            current.put("label", app.loadLabel(manager).toString());
                            current.put("icon", iconData);
                            current.put("package", app.packageName);
                            _output.add(current);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                return null;
            }

            @Override
            protected void onPostExecute(Object o) {
                super.onPostExecute(o);
                mResult.success(_output);
            }
        }.execute(result);

    }

    public static byte[] convertToBytes(Bitmap image, Bitmap.CompressFormat compressFormat, int quality) {
        ByteArrayOutputStream byteArrayOS = new ByteArrayOutputStream();
        image.compress(compressFormat, quality, byteArrayOS);
        return byteArrayOS.toByteArray();
    }

    private Bitmap getBitmapFromDrawable(Drawable drawable) {
        final Bitmap bmp = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        final Canvas canvas = new Canvas(bmp);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bmp;
    }

    private void getWallpaper(MethodChannel.Result result) {
//        if (wallpaperData != null) {
//            result.success(wallpaperData);
//            return;
//        }

        WallpaperManager wallpaperManager = WallpaperManager.getInstance(getApplicationContext());
        Drawable wallpaperDrawable = wallpaperManager.getDrawable();
        if (wallpaperDrawable instanceof BitmapDrawable) {
            byte[] wallpaperData = convertToBytes(((BitmapDrawable) wallpaperDrawable).getBitmap(),
                    Bitmap.CompressFormat.JPEG, 100);
            result.success(wallpaperData);
        }
    }

    private void launchApp(String packageName) {
        Intent i = getApplicationContext().getPackageManager().getLaunchIntentForPackage(packageName);
        if (i != null) {
            getApplicationContext().startActivity(i);
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
        }
    }


}
