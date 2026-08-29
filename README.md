# House Design — Flutter Source

Feature-first Flutter app: dashboard, 2D/3D template galleries, interior
designs, and a bricks (masonry) calculator. State management is Riverpod.

## Structure
```
lib/
  main.dart                          entry point (wraps app in ProviderScope)
  app.dart                           MaterialApp + theme
  core/theme/app_theme.dart          colors + Material 3 ThemeData
  models/template_model.dart         shared model for all template cards
  services/api_service.dart          HouseApiService — mock data now, real
                                      endpoints commented in for later
  features/
    home/                            dashboard: banner, 6-card menu, options sheet
    templates/                       TemplateScreen(is2D: true/false) + providers
    interior/                        Interior Designs gallery
    calculator/                      Bricks Calculator
    create/                          "Create New" blank-canvas placeholder
    creations/                       "My Creation" saved-designs placeholder
```

## Run it
1. Drop the `lib/` folder (and merge `pubspec.yaml` dependencies) into your
   Flutter project, or use this as a standalone project.
2. `flutter pub get`
3. `flutter run`

## Wiring up your real API
Open `lib/services/api_service.dart` — each fetch method has the mock line
plus a commented-out `http.get(...)` block. Set `baseUrl`, add your auth
header in `_headers`, then swap the mock line for the real call and delete
the corresponding mock list at the bottom of the file once verified.

## Notes
- Illustration/graphics (house icon in the banner, isometric wall on the
  calculator) are lightweight placeholders — swap them for real image/Lottie
  assets when you have them.
- `Image`/`CachedNetworkImage` calls already handle empty/broken URLs with a
  fallback icon, so the UI won't break while `imageUrl` is still blank in
  mock data.
- "Remove Ads", "Customer Support", "Rate Us", "Share" etc. in the options
  sheet are stubbed (`onTap: () {}`) — wire each to `in_app_purchase`,
  `url_launcher`, `share_plus` etc. as needed.
