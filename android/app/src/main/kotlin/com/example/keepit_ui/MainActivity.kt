package app.keepit

import android.os.Build
import android.os.Environment
import android.os.StatFs
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.keepit/battery"

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->

            if(call.method == "getExternalStorageTotalSpace"){
                result.success(getExternalStorageTotalSpace());
            }
            else if(call.method == "getExternalStorageFreeSpace"){
                result.success(getExternalStorageFreeSpace());
            }
            else if(call.method == "getStorageTotalSpace"){
                result.success(getStorageTotalSpace());
            }
            else if(call.method == "getStorageFreeSpace"){
                result.success(getStorageFreeSpace());
            }
            
        }
    }

//    fun getTotalExternalMemorySize(): Int {
//        val path: File = Environment.getExternalStorageDirectory()
//        val stat = StatFs(path.getPath())
//        val blockSize = stat.getBlockSize().toInt()
//        val totalBlocks = stat.getBlockCount().toInt()
//        return totalBlocks * blockSize;
//    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun getExternalStorageTotalSpace(): Long{
        val dirs: Array<File> = getExternalFilesDirs(null)
        val stat = StatFs(dirs[1].path.split("Android")[0])

        return stat.totalBytes
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT)
    fun getExternalStorageFreeSpace(): Int{
        val dirs: Array<File> = getExternalFilesDirs(null)
        val stat = StatFs(dirs[1].path.split("Android")[0])
        return stat.availableBytes.toInt()
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    fun getStorageTotalSpace(): Long{
        val path = Environment.getDataDirectory()
        val stat = StatFs(path.path)
        return stat.totalBytes
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    fun getStorageFreeSpace(): Long{
        val path = Environment.getDataDirectory()
        val stat = StatFs(path.path)
        return stat.availableBytes
    }
}
