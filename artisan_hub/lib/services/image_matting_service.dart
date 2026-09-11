import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

/// Pure Dart client-side background removal and studio matting engine.
/// Works 100% offline with zero external server or API requirements.
class ImageMattingService {
  /// Removes background from [imageBytes] and returns a base64 PNG data URL with transparent background.
  static Future<String?> removeBackground(Uint8List imageBytes) async {
    try {
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;
      final int width = image.width;
      final int height = image.height;

      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return null;

      final Uint8List pixels = Uint8List.fromList(byteData.buffer.asUint8List());

      // 1. Sample border and corner background colors
      final List<List<int>> bgSamples = [];
      
      // Sample 4 corners
      bgSamples.add(_getPixelRgb(pixels, width, 0, 0));
      bgSamples.add(_getPixelRgb(pixels, width, width - 1, 0));
      bgSamples.add(_getPixelRgb(pixels, width, 0, height - 1));
      bgSamples.add(_getPixelRgb(pixels, width, width - 1, height - 1));

      // Sample border midpoints
      bgSamples.add(_getPixelRgb(pixels, width, width ~/ 2, 0));
      bgSamples.add(_getPixelRgb(pixels, width, width ~/ 2, height - 1));
      bgSamples.add(_getPixelRgb(pixels, width, 0, height ~/ 2));
      bgSamples.add(_getPixelRgb(pixels, width, width - 1, height ~/ 2));

      // Additional perimeter samples
      for (int i = 1; i <= 3; i++) {
        final x = (width * i) ~/ 4;
        final y = (height * i) ~/ 4;
        bgSamples.add(_getPixelRgb(pixels, width, x, 0));
        bgSamples.add(_getPixelRgb(pixels, width, x, height - 1));
        bgSamples.add(_getPixelRgb(pixels, width, 0, y));
        bgSamples.add(_getPixelRgb(pixels, width, width - 1, y));
      }

      final double cx = width / 2.0;
      final double cy = height / 2.0;
      final double maxRadius = sqrt(cx * cx + cy * cy);

      // 2. Compute alpha mask for each pixel
      const double lowThresh = 28.0;
      const double highThresh = 65.0;

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int offset = (y * width + x) * 4;
          final int r = pixels[offset];
          final int g = pixels[offset + 1];
          final int b = pixels[offset + 2];

          // Minimum color distance to any perimeter background sample
          double minBgDist = double.infinity;
          for (final sample in bgSamples) {
            final double dr = (r - sample[0]).toDouble();
            final double dg = (g - sample[1]).toDouble();
            final double db = (b - sample[2]).toDouble();
            final double dist = sqrt(dr * dr + dg * dg + db * db);
            if (dist < minBgDist) {
              minBgDist = dist;
            }
          }

          // Distance from center of image (0.0 at center, 1.0 at farthest corner)
          final double dx = x - cx;
          final double dy = y - cy;
          final double distFromCenter = sqrt(dx * dx + dy * dy) / maxRadius;

          // Adaptive threshold: center pixels require higher color confidence to be keyed out
          final double adaptiveLow = lowThresh * (1.0 - 0.3 * (1.0 - distFromCenter));
          final double adaptiveHigh = highThresh * (1.0 - 0.3 * (1.0 - distFromCenter));

          double alphaFactor = 1.0;
          if (minBgDist <= adaptiveLow) {
            alphaFactor = 0.0;
          } else if (minBgDist < adaptiveHigh) {
            alphaFactor = (minBgDist - adaptiveLow) / (adaptiveHigh - adaptiveLow);
          }

          // If pixel is very close to extreme borders and resembles background, force transparent
          if ((x < 3 || x >= width - 3 || y < 3 || y >= height - 3) && minBgDist < adaptiveHigh) {
            alphaFactor = 0.0;
          }

          pixels[offset + 3] = (pixels[offset + 3] * alphaFactor).round().clamp(0, 255);
        }
      }

      // 3. Re-encode to PNG
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromPixels(
        pixels,
        width,
        height,
        ui.PixelFormat.rgba8888,
        (ui.Image img) => completer.complete(img),
      );
      final ui.Image transparentImage = await completer.future;
      final ByteData? pngByteData = await transparentImage.toByteData(format: ui.ImageByteFormat.png);

      if (pngByteData == null) return null;

      final pngBytes = pngByteData.buffer.asUint8List();
      return "data:image/png;base64,${base64Encode(pngBytes)}";
    } catch (e) {
      return null;
    }
  }

  static List<int> _getPixelRgb(Uint8List pixels, int width, int x, int y) {
    final int offset = (y * width + x) * 4;
    return [pixels[offset], pixels[offset + 1], pixels[offset + 2]];
  }
}
