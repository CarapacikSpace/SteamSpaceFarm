import 'package:material_ui/material_ui.dart';

class const SteamImageWithFallback({
  required final List<String> imageUrls,
  required final Widget fallback,
  final BoxFit fit = BoxFit.cover,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _SteamImageAttempt(
    imageUrls: imageUrls.where((url) => url.isNotEmpty).toList(growable: false),
    index: 0,
    fit: fit,
    fallback: fallback,
  );
}

class const _SteamImageAttempt({
  required final List<String> imageUrls,
  required final int index,
  required final BoxFit fit,
  required final Widget fallback,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (index >= imageUrls.length) {
      return fallback;
    }

    return Image.network(
      imageUrls[index],
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) =>
          loadingProgress == null ? child : const ColoredBox(color: Color(0xFF19212D)),
      errorBuilder: (_, _, _) =>
          _SteamImageAttempt(imageUrls: imageUrls, index: index + 1, fit: fit, fallback: fallback),
    );
  }
}

class const SteamImageTextFallback({required final String text, super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF19212D),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          text,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
        ),
      ),
    ),
  );
}
