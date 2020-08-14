package host.exp.exponent.experience.splashscreen

import android.content.Context
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.AlphaAnimation
import android.widget.ImageView
import com.squareup.picasso.Callback
import com.squareup.picasso.Picasso
import expo.modules.splashscreen.SplashScreenImageResizeMode
import expo.modules.splashscreen.SplashScreenView
import expo.modules.splashscreen.SplashScreenViewProvider
import host.exp.exponent.analytics.EXL
import org.json.JSONObject

/**
 * SplashScreenView provider that parses manifest and extracts splash configuration.
 * It allows reconfiguration of the SplashScreenImage.
 */
class ManagedAppSplashScreenViewProvider(
  private var config: ManagedAppSplashScreenConfiguration
) : SplashScreenViewProvider {
  private lateinit var splashScreenView: SplashScreenView

  companion object {
    private const val TAG: String = "ExperienceSplashScreenManifestBasedResourceProvider"
  }

  override fun createSplashScreenView(context: Context): View {
    splashScreenView = SplashScreenView(context)
    configureSplashScreenView(context, config)
    return splashScreenView
  }

  fun updateSplashScreenViewWithManifest(context: Context, manifest: JSONObject) {
    config = ManagedAppSplashScreenConfiguration.parseManifest(manifest)
    configureSplashScreenView(context, config)
  }

  private fun configureSplashScreenView(context: Context, config: ManagedAppSplashScreenConfiguration) {
    splashScreenView.setBackgroundColor(config.backgroundColor)
    splashScreenView.configureImageViewResizeMode(config.resizeMode)
    configureSplashScreenImageView(context, config)
  }

  private fun configureSplashScreenImageView(context: Context, config: ManagedAppSplashScreenConfiguration) {
    splashScreenView.imageView.visibility = View.GONE
    if (config.imageUrl == null) {
      return
    }
    Picasso.with(context).load(config.imageUrl).into(splashScreenView.imageView, object : Callback {
      override fun onSuccess() {
        splashScreenView.imageView.visibility = View.VISIBLE
        splashScreenView.imageView.animation = AlphaAnimation(0.0f, 1.0f).also {
          it.duration = 300
          it.interpolator = AccelerateDecelerateInterpolator()
          it.fillAfter = true
        }
      }

      override fun onError() {
        EXL.e(TAG, "Couldn't load image at url " + config.imageUrl)
      }
    })
  }
}