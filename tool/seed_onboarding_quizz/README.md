# Onboarding quizz — Firestore

The onboarding quizz is read from the `OnboardingQuizz` collection: one document
per step, the document id being the step key. When Firestore fails or the
collection is empty, the app falls back on `assets/data/onboarding_quizz.json`,
which is also what this script seeds.

## Seeding

```sh
cd tool/seed_onboarding_quizz
npm install
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json node seed.mjs --dry-run
GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json node seed.mjs
```

- Only the missing steps are created: console edits are kept.
- `--overwrite` replaces every step with the bundled version.
- `FIREBASE_PROJECT_ID` overrides the project (default `recipe-ai-5e261`).
- The service account key comes from Firebase console › Project settings ›
  Service accounts. Never commit it.

## Security rules

The collection must be readable by signed-in users and never writable from
the app:

```
match /OnboardingQuizz/{step} {
  allow read: if request.auth != null;
  allow write: if false;
}
```

## Editing from the console

A step document:

| Field | Values |
| --- | --- |
| `order` | Display order (number). |
| `enabled` | `false` hides the step. |
| `kind` | `options`, `morphology` or `chips`. A new kind needs a release. |
| `selectionMode` | `single` or `multiple`. |
| `tileStyle` | `colorDot`, `iconTile` or `smallDot`. |
| `isRequired` | `false` lets the user continue without answering. |
| `exclusiveOptionKey` | Option that clears the others ("Aucune"). |
| `title`, `helper`, `footnote` | `{fr: "…", en: "…"}`. |
| `otherField` | Free text field: `{preferenceKey, hint: {fr, en}, title?: {fr, en}}`. |
| `options` | `[{key, label: {fr, en}, description?: {fr, en}, color?: "#RRGGBB", icon?: "name"}]`, in display order. |
| `sections` | `chips` steps only: `[{title: {fr, en}, options: [...]}]`. |

Rules of thumb:

- **Never rename or reuse an option `key`**: it is the field written in the
  user preferences (`UserPreference/{uid}`). Keys must be unique across the
  whole quizz.
- `icon` must be one of the names of `onboardingIcons` in
  `lib/user_preferences/presentation/onboarding_display.dart`; an unknown name
  shows a neutral circle.
- A malformed option or step is skipped by the app rather than crashing it.
- The app reads the catalogue once per launch: changes show on the next
  launch.
- Keep `assets/data/onboarding_quizz.json` in sync with the console when
  releasing, so the offline fallback stays current.
