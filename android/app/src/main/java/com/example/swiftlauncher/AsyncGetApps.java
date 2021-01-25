//package com.example.swiftlauncher;
//
//import android.content.Context;
//import android.content.Intent;
//import android.content.pm.LauncherActivityInfo;
//import android.content.pm.LauncherApps;
//import android.content.pm.ResolveInfo;
//import android.os.AsyncTask;
//import android.os.Build;
//import android.os.UserHandle;
//
//import java.text.Collator;
//import java.util.ArrayList;
//import java.util.Collections;
//import java.util.Comparator;
//import java.util.List;
//
//public class AsyncGetApps extends AsyncTask {
//    private List<App> appsTemp;
//    private List<App> nonFilteredAppsTemp;
//
//    @Override
//    protected void onPreExecute() {
//        appsTemp = new ArrayList<>();
//        nonFilteredAppsTemp = new ArrayList<>();
//        super.onPreExecute();
//    }
//
//    @Override
//    protected void onCancelled() {
//        appsTemp = null;
//        nonFilteredAppsTemp = null;
//        super.onCancelled();
//    }
//
//    @Override
//    protected Object doInBackground(Object[] p1) {
//
//        // work profile support
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            LauncherApps launcherApps = (LauncherApps) _context.getSystemService(Context.LAUNCHER_APPS_SERVICE);
//            List<UserHandle> profiles = launcherApps.getProfiles();
//            for (UserHandle userHandle : profiles) {
//                List<LauncherActivityInfo> apps = launcherApps.getActivityList(null, userHandle);
//                for (LauncherActivityInfo info : apps) {
//                    App app = new App(_packageManager, info);
//                    app._userHandle = userHandle;
//
//                    LOG.debug("adding work profile to non filtered list: {}, {}, {}", app._label, app._packageName, app._className);
//                    nonFilteredAppsTemp.add(app);
//                }
//            }
//        } else {
//            Intent intent = new Intent(Intent.ACTION_MAIN, null);
//            intent.addCategory(Intent.CATEGORY_LAUNCHER);
//            List<ResolveInfo> activitiesInfo = _packageManager.queryIntentActivities(intent, 0);
//            for (ResolveInfo info : activitiesInfo) {
//                App app = new App(_packageManager, info);
//
//                LOG.debug("adding app to non filtered list: {}, {}, {}", app._label,  app._packageName, app._className);
//                nonFilteredAppsTemp.add(app);
//            }
//        }
//
//        // sort the apps by label here
//        Collections.sort(nonFilteredAppsTemp, new Comparator<App>() {
//            @Override
//            public int compare(App one, App two) {
//                return Collator.getInstance().compare(one._label, two._label);
//            }
//        });
//
//        List<String> hiddenList = AppSettings.get().getHiddenAppsList();
//        if (hiddenList != null) {
//            for (int i = 0; i < nonFilteredAppsTemp.size(); i++) {
//                boolean shouldGetAway = false;
//                for (String hidItemRaw : hiddenList) {
//                    if ((nonFilteredAppsTemp.get(i).getComponentName()).equals(hidItemRaw)) {
//                        shouldGetAway = true;
//                        break;
//                    }
//                }
//                if (!shouldGetAway) {
//                    appsTemp.add(nonFilteredAppsTemp.get(i));
//                }
//            }
//        } else {
//            appsTemp.addAll(nonFilteredAppsTemp);
//        }
//
//        AppSettings appSettings = AppSettings.get();
//        if (!appSettings.getIconPack().isEmpty() && Tool.isPackageInstalled(appSettings.getIconPack(), _packageManager)) {
//            IconPackHelper.applyIconPack(AppManager.this, Tool.dp2px(appSettings.getIconSize()), appSettings.getIconPack(), appsTemp);
//        }
//        return null;
//    }
//
//    @Override
//    protected void onPostExecute(Object result) {
//        List<App> removed = getRemovedApps(_apps, appsTemp);
//
//        _apps = appsTemp;
//        _nonFilteredApps = nonFilteredAppsTemp;
//
//        notifyUpdateListeners(appsTemp);
//
//        if (removed.size() > 0) {
//            notifyRemoveListeners(removed);
//        }
//
//        if (_recreateAfterGettingApps) {
//            _recreateAfterGettingApps = false;
//            if (_context instanceof HomeActivity)
//                ((HomeActivity) _context).recreate();
//        }
//
//        super.onPostExecute(result);
//    }
//}