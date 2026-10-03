package com.adguard.trusttunnel.vpn_plugin

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.os.Build
import com.adguard.trusttunnel.Logger
import java.io.ByteArrayOutputStream

/**
 * Lists launchable applications for per-app routing (split tunneling).
 *
 * Visibility of other packages on Android 11+ relies on the MAIN/LAUNCHER `<queries>`
 * entry declared in this plugin's manifest.
 */
class InstalledAppsImpl(private val context: Context) : IInstalledApps {

    companion object {
        // Rows show 40dp icons; 128px stays sharp up to xxhdpi while keeping PNGs small.
        private const val ICON_SIZE_PX = 128
    }

    private val log = Logger("VPN_PLUGIN")

    override fun getInstalledApps(): List<PlatformInstalledApp> {
        val packageManager = context.packageManager
        val selfPackageName = context.packageName
        // Apps with several launcher activities must be listed once.
        val appsByPackage = LinkedHashMap<String, PlatformInstalledApp>()
        for (resolveInfo in queryLauncherActivities(packageManager)) {
            val appInfo = resolveInfo.activityInfo?.applicationInfo ?: continue
            val packageName = appInfo.packageName ?: continue
            if (packageName == selfPackageName || appsByPackage.containsKey(packageName)) {
                continue
            }
            val label = packageManager.getApplicationLabel(appInfo).toString().ifBlank { packageName }
            val systemFlags = ApplicationInfo.FLAG_SYSTEM or ApplicationInfo.FLAG_UPDATED_SYSTEM_APP
            appsByPackage[packageName] = PlatformInstalledApp(
                packageName = packageName,
                label = label,
                isSystem = appInfo.flags and systemFlags != 0,
            )
        }
        log.info("getInstalledApps() -> ${appsByPackage.size} launchable apps")
        return appsByPackage.values.toList()
    }

    override fun getAppIcon(packageName: String): ByteArray? {
        val drawable = try {
            context.packageManager.getApplicationIcon(packageName)
        } catch (e: PackageManager.NameNotFoundException) {
            log.debug("getAppIcon(): $packageName is not installed")
            return null
        }
        // Drawing through a Canvas handles bitmap and adaptive icons alike.
        val bitmap = Bitmap.createBitmap(ICON_SIZE_PX, ICON_SIZE_PX, Bitmap.Config.ARGB_8888)
        try {
            drawable.setBounds(0, 0, ICON_SIZE_PX, ICON_SIZE_PX)
            drawable.draw(Canvas(bitmap))
            return ByteArrayOutputStream().use { stream ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                stream.toByteArray()
            }
        } finally {
            bitmap.recycle()
        }
    }

    private fun queryLauncherActivities(packageManager: PackageManager): List<ResolveInfo> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.queryIntentActivities(
                intent,
                PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_ALL.toLong()),
            )
        } else {
            @Suppress("DEPRECATION")
            packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
        }
    }
}
