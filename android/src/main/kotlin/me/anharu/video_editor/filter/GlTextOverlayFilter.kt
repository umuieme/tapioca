package me.anharu.video_editor.filter

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import com.daasuu.mp4compose.filter.GlOverlayFilter
import me.anharu.video_editor.TextOverlay
import android.text.TextPaint
import android.text.StaticLayout
import android.text.Layout
class GlTextOverlayFilter(textOverlay: TextOverlay) : GlOverlayFilter() {
    private val textOverlay: TextOverlay = textOverlay;

    protected override fun drawCanvas(canvas: Canvas) {
        val bitmap: Bitmap = textAsBitmap(textOverlay.text, textOverlay.size.toFloat(), textOverlay.color,textOverlay.background)
        canvas.drawBitmap(bitmap, textOverlay.x.toFloat(), textOverlay.y.toFloat(), null);
    }
    private fun textAsBitmap(text: String, textSize: Float, color: String,background:String): Bitmap {


        val textPaint = TextPaint(Paint.ANTI_ALIAS_FLAG or Paint.LINEAR_TEXT_FLAG)
        textPaint.setStyle(Paint.Style.FILL)
        textPaint.setColor(Color.parseColor(background))
        textPaint.setTextSize(30f)
        val textWidth = (textPaint.measureText(text) + 0.5f).toInt() // roundx
        val heights = 100
        val mTextLayout = StaticLayout(text, textPaint, textWidth, Layout.Alignment.ALIGN_CENTER, 1.0f, 0.0f, false)

        // Create bitmap and canvas to draw to

        // Create bitmap and canvas to draw to
        val b: Bitmap = Bitmap.createBitmap(textWidth, mTextLayout.getHeight(), Bitmap.Config.ARGB_4444)
        val c = Canvas(b)

        // Draw background

        // Draw background
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.LINEAR_TEXT_FLAG)
        paint.setStyle(Paint.Style.FILL)
        c.drawPaint(paint)

        // Draw text

        // Draw text
        c.save()
        c.translate(0f, 0f)
        mTextLayout.draw(c)
        c.restore()

        return b





    }
}