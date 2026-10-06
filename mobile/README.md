# jules mobile 📱

Stylish phone client for [Jules](https://jules.google.com) — same backend + same frontend, zero features removed, phone-grade UI on top.

- **App:** `jules` · **Org:** `octavian.com` → `applicationId octavian.com.jules`
- **Web tab:** real `jules.google.com` in a rounded card with back/forward/reload, gradient progress, mobile touch polish (44px targets, AMOLED match)
- **Sessions:** native list on `GET /v1alpha/sessions` — search, All/Working/Done filter, shimmer skeletons, Hero → detail (status, prompt, PR link, share)
- **New task (FAB):** 6 power presets (Architect, Bug Hunter, Perf, Security, Tests, Refactor) with guardrails + verify loop, Deep/History/Strict toggles, Auto-PR vs Ask-approval, extra context paste, prompt preview
- **Glow:** endless conical border (blue→green→purple→red→white→violet) ON while the agent codes, OFF when idle — driven by `AgentState`
- **Theme:** AMOLED dark + light, glass cards, aurora background, Lottie, haptics

## Build the APK (cloud — recommended)

Push `mobile/**` → GitHub Actions **`mobile-apk`** runs:

1. `flutter create` Android shell if missing (never overwrites `lib/`)
2. `flutter pub get` → `flutter analyze` → `flutter test`
3. `flutter build apk --debug` → artifact **`jules-debug-apk`**

Download it from the Actions run → install on your phone.

## Local dev

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

API key: Settings tab → paste `JULES_API_KEY` from `jules.google.com` (stored only on-device via secure storage, never committed).
