package com.example.swiftlauncher;

import android.app.WallpaperManager;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;
import android.app.SearchManager;

import org.json.JSONArray;
import org.json.JSONException;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.net.Uri;
import android.graphics.Bitmap;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "launcher_assist";
    private byte[] wallpaperData = null;
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("getAllApps")) {
                                getAllApps(result);
                            } else if(call.method.equals("launchApp")) {
                                launchApp(call.argument("packageName").toString());
                            } else if(call.method.equals("getWallpaper")) {
                                getWallpaper(result);
                            } else if (call.method.equals("searchGoogle")){
                                searchGoogle(call.argument("query").toString());
                            }
                             else if (call.method.equals("searchPlaystore")){
                                searchPlaystore(call.argument("query").toString());
                            } else if (call.method.equals("searchYoutube")){
                                searchYoutube(call.argument("query").toString());
                            }
                             else if (call.method.equals("searchVanced")){
                                searchVanced(call.argument("query").toString());
                            }
                             else if (call.method.equals("openSetting")){
                                openSetting(call.argument("package").toString());
                            } else if (call.method.equals("getIconPacks")){
                                getIconPacks(result);
                            }
                            else if (call.method.equals("getIcon")){
                                getIconFromPack(result,call.argument("pckg").toString(),call.argument("key").toString());
                            }
                        }
                );
    }
    
    //TODO GET ICON FROM PACK THAT IS GIVEN
    private void getIconFromPack(MethodChannel.Result result, String packageName, String key){
        IconPackManager manager = new IconPackManager();
        manager.setContext(getApplication());
        HashMap<String, IconPackManager.IconPack> map = manager.getAvailableIconPacks(false);
        IconPackManager.IconPack pack = map.get(packageName);
        pack.load();
        Bitmap bitmap = pack.getIconForPackage(key, null);
        if (bitmap == null){
            result.success(null);
        }else{
           
            result.success(convertToBytes(bitmap,Bitmap.CompressFormat.PNG, 100));
        }
    }

    private void  getIconPacks(MethodChannel.Result result){
        IconPackManager manager = new IconPackManager();
        manager.setContext(getApplication());
        HashMap<String, IconPackManager.IconPack> map = manager.getAvailableIconPacks(true);
        String toSend = "";
        for(String key : map.keySet()){
            toSend+=map.get(key).name+","+map.get(key).packageName+"\n";
        }
        result.success(toSend);
    }


    private void openSetting(String packageName){
        Intent intent = new Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
        intent.setData(Uri.parse("package:" + packageName));
        startActivity(intent); 
    }
    
    private void searchGoogle(String search){
        final Intent intent = new Intent(Intent.ACTION_WEB_SEARCH);
        intent.setPackage("com.google.android.googlequicksearchbox");
        intent.putExtra(SearchManager.QUERY, search);
        startActivity(intent);
    }
    private void searchPlaystore(String query){
        Intent goToMarket = new Intent(Intent.ACTION_VIEW).setData(Uri.parse("market://search?q="+query));
startActivity(goToMarket);
    }
    private void searchYoutube(String query){
        Intent intent = new  Intent(Intent.ACTION_VIEW);
         intent.setPackage("com.google.android.youtube");    
         intent.setData(Uri.parse("https://www.youtube.com/results?search_query="+query));
         startActivity(intent);
    }
    private void searchVanced(String query){
        Intent intent = new  Intent(Intent.ACTION_VIEW);
         intent.setPackage("com.vanced.android.youtube");    
         intent.setData(Uri.parse("https://www.youtube.com/results?search_query="+query));
         startActivity(intent);
    }
    private void getAllApps(MethodChannel.Result result) {

        Intent intent = new Intent(Intent.ACTION_MAIN, null);
        intent.addCategory(Intent.CATEGORY_LAUNCHER);

        PackageManager manager = getApplicationContext().getPackageManager();
        List<ResolveInfo> resList = manager.queryIntentActivities(intent, 0);

        List<Map<String, Object>> _output = new ArrayList<>();

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

        result.success(_output);
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
        if(wallpaperData != null) {
            result.success(wallpaperData);
            return;
        }
  
        WallpaperManager wallpaperManager = WallpaperManager.getInstance(getApplicationContext());
        Drawable wallpaperDrawable = wallpaperManager.getDrawable();
        if(wallpaperDrawable instanceof BitmapDrawable) {
            wallpaperData = convertToBytes(((BitmapDrawable)wallpaperDrawable).getBitmap(),
                                                  Bitmap.CompressFormat.JPEG, 100);
            result.success(wallpaperData);
        }
    }
  
    private void launchApp(String packageName) {
        Intent i = getApplicationContext().getPackageManager().getLaunchIntentForPackage(packageName);
        if(i != null)
        getApplicationContext().startActivity(i);
    }
}
