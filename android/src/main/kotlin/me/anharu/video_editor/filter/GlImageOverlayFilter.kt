package me.anharu.video_editor.filter

import android.graphics.*
import com.daasuu.mp4compose.filter.GlOverlayFilter
import me.anharu.video_editor.ImageOverlay
import android.graphics.Bitmap

import android.R.attr.src

import android.graphics.BitmapFactory

import android.R.attr.bitmap





class GlImageOverlayFilter(imageOverlay: ImageOverlay) : GlOverlayFilter() {
    private val imageOverlay: ImageOverlay = imageOverlay;

    protected override fun drawCanvas(canvas: Canvas) {
        var b = BitmapFactory.decodeByteArray (imageOverlay.bitmap, 0, imageOverlay.bitmap.size)
        var bitmap= getResizedBitmap(b, b.height/10, b.width/10)
        //    Bitmap.createScaledBitmap(b, b.width/2, b.height/2, true);
        canvas.drawBitmap(bitmap, imageOverlay.x.toFloat(), imageOverlay.y.toFloat(), null);
    }
    fun scaleBitmap(bitmap: Bitmap, wantedWidth: Int, wantedHeight: Int): Bitmap {
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
        val scaleWidth = newHeight.toFloat() / width
        val scaleHeight = newHeight.toFloat() / height
        // create a matrix for the manipulation
        val matrix = Matrix()
        // resize the bit map
        matrix.postScale(scaleWidth, scaleHeight)
        // recreate the new Bitmap
        return Bitmap.createBitmap(bm, 0, 0, width, height, matrix, true)
    }
}