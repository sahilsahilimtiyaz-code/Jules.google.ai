# jules mobile

Stylish phone client for Jules. Same backend + frontend as Jules web, zero features removed.

- App name: `jules`
- Org / package base: `octavian.com` → applicationId becomes `octavian.com.jules` after `flutter create --org octavian.com --project-name jules`
- Web tab loads `https://jules.google.com` with mobile CSS/JS polish (AMOLED, touch targets)
- Native tabs use same API as `../action.yaml`: `POST https://jules.googleapis.com/v1alpha/sessions` with `X-Goog-Api-Key`

## Cloud build APK
Push `mobile/**` → GitHub Actions `mobile-apk` builds debug APK → download from Artifacts `jules-debug-apk`.

No on-phone build needed (too heavy for phone CI).
