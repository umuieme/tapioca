package me.anharu.video_editor.filter

import android.graphics.*
import com.daasuu.mp4compose.filter.GlOverlayFilter
import me.anharu.video_editor.ImageOverlay
import android.graphics.Bitmap

import android.graphics.BitmapFactory


import java.io.ByteArrayOutputStream










class GlImageOverlayFilter(imageOverlay: ImageOverlay) : GlOverlayFilter() {
    private val imageOverlay: ImageOverlay = imageOverlay;

    protected override fun drawCanvas(canvas: Canvas) {

        var b = BitmapFactory.decodeByteArray (imageOverlay.bitmap, 0, imageOverlay.bitmap.size)
        var bitmap= scaleBitmap(b, b.width/2, b.height/2)
        //    Bitmap.createScaledBitmap(b, b.width/2, b.height/2, true);
        canvas.drawBitmap(bitmap, imageOverlay.x.toFloat(), imageOverlay.y.toFloat(),null);

    }
    fun scaleBitmaps(bitmap: Bitmap, wantedWidth: Int, wantedHeight: Int): Bitmap {
        val output = Bitmap.createBitmap(wantedWidth, wantedHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val m = Matrix()
        m.setScale(wantedWidth.toFloat() / bitmap.width, wantedHeight.toFloat() / bitmap.height)
        canvas.drawBitmap(bitmap,m, Paint(Paint.FILTER_BITMAP_FLAG))
        return output
    }

    fun getResizedBitmap(bm: Bitmap, newHeight: Int, newWidth: Int): Bitmap {
        val width = bm.width
        val height = bm.height
        val scaleWidth = newWidth.toFloat() / width
        val scaleHeight = newHeight.toFloat() / height
        // create a matrix for the manipulation
        val matrix = Matrix()
        // resize the bit map
        matrix.postScale(scaleWidth, scaleHeight)

        // recreate the new Bitmap
        var dd= Bitmap.createBitmap(bm, 0, 0, width, height, matrix, true)
        var outputStream = ByteArrayOutputStream()
        dd.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
        return  dd;

    }
    fun scaleBitmap(bitmap: Bitmap, wantedWidth: Int, wantedHeight: Int): Bitmap {
        val originalWidth = bitmap.width.toFloat()
        val originalHeight = bitmap.height.toFloat()
        val output = Bitmap.createBitmap(wantedWidth, wantedHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(output)
        val m = Matrix()
        val scalex = wantedWidth / originalWidth
        val scaley = wantedHeight / originalHeight
        val xTranslation = 0.0f
        val yTranslation = (wantedHeight - originalHeight * scaley) / 2.0f
        m.postTranslate(xTranslation, yTranslation)
        m.preScale(scalex, scaley)
        // m.setScale((float) wantedWidth / bitmap.getWidth(), (float) wantedHeight / bitmap.getHeight());
        val paint = Paint()
        paint.isFilterBitmap = true
        canvas.drawBitmap(bitmap, m, paint)
        return output
    }
}