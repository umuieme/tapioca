package me.anharu.video_editor.filter

import android.R.attr.path
import android.graphics.*
import com.daasuu.mp4compose.filter.GlOverlayFilter
import me.anharu.video_editor.ImageOverlay


class GlImageOverlayFilter(imageOverlay: ImageOverlay) : GlOverlayFilter() {
    private val imageOverlay: ImageOverlay = imageOverlay;

    protected override fun drawCanvas(canvas: Canvas) {
        var b = BitmapFactory.decodeByteArray (imageOverlay.bitmap, 0, imageOverlay.bitmap.size)
         var bitmap= scaleBitmap(b, b.width, b.height);
//
        // var bitmap=Bitmap.createScaledBitmap(b, b.width, b.height, true);

        canvas.drawBitmap(bitmap, imageOverlay.x.toFloat(), imageOverlay.y.toFloat(), Paint(2));
//        canvas.scale(2f, 2f);


    }
    fun scaleBitmap(bitmap: Bitmap, wantedWidth: Int, wantedHeight: Int): Bitmap {
        val output = Bitmap.createBitmap(wantedWidth, wantedHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val m = Matrix()
        m.setScale(wantedWidth.toFloat() / bitmap.width, wantedHeight.toFloat() / bitmap.height)
        canvas.drawBitmap(bitmap, m, Paint())
        return output
    }
}