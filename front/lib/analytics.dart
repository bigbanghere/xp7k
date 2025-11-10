import 'dart:js' as js;

/// Vercel Analytics integration for Flutter Web
class VercelAnalytics {
  static bool _initialized = false;

  /// Initialize Vercel Analytics
  /// This should be called once when the app starts
  /// Note: The script is loaded automatically by Vercel, we just check if it's available
  static void init() {
    if (_initialized) return;
    
    try {
      // Check if va (Vercel Analytics) is available
      final va = js.context['va'];
      if (va != null) {
        _initialized = true;
        print('Vercel Analytics initialized');
      } else {
        // Also check for vercelAnalytics wrapper (set up in index.html)
        final vercelAnalytics = js.context['vercelAnalytics'];
        if (vercelAnalytics != null) {
          _initialized = true;
          print('Vercel Analytics initialized (via wrapper)');
        } else {
          print('Vercel Analytics not available yet, will retry');
          // Retry after a delay
          Future.delayed(const Duration(seconds: 1), () {
            if (!_initialized) {
              init();
            }
          });
        }
      }
    } catch (e) {
      print('Error initializing Vercel Analytics: $e');
    }
  }

  /// Track a page view
  /// Vercel Analytics automatically tracks page views via the script
  /// This method is kept for compatibility but page views are auto-tracked
  static void trackPageView({String? path, String? title}) {
    try {
      // Vercel Analytics automatically tracks page views
      // We can manually trigger a page view by updating the URL
      if (path != null) {
        // Update browser history to trigger page view
        final history = js.context['history'];
        if (history != null) {
          final pushState = history['pushState'];
          if (pushState != null) {
            pushState.apply([js.JsObject.jsify({}), '', path]);
          }
        }
      }
      // Note: Vercel Analytics will automatically track this as a page view
    } catch (e) {
      print('Error tracking page view: $e');
    }
  }

  /// Track a custom event
  static void trackEvent(String name, {Map<String, String>? properties}) {
    try {
      // Try using vercelAnalytics wrapper first
      final vercelAnalytics = js.context['vercelAnalytics'];
      if (vercelAnalytics != null) {
        final track = vercelAnalytics['track'];
        if (track != null) {
          // Use the wrapper's track function
          if (properties != null) {
            final props = js.JsObject.jsify(properties);
            track.apply([name, props]);
          } else {
            track.apply([name]);
          }
          print('Tracked event: $name');
          return;
        }
      }
      
      // Fallback: use va.track directly
      final va = js.context['va'];
      if (va != null) {
        final vaTrack = va['track'];
        if (vaTrack != null) {
          if (properties != null) {
            final props = js.JsObject.jsify(properties);
            vaTrack.apply([name, props]);
          } else {
            vaTrack.apply([name]);
          }
          print('Tracked event via va.track: $name');
        }
      }
    } catch (e) {
      print('Error tracking event: $e');
    }
  }
}

