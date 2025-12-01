<!-- .github/copilot-instructions.md - Project-specific instructions for AI coding agents -->
# Copilot instructions — TEST (Crop Claim Flutter app)

Purpose: short, actionable guidance for an AI coding agent to be immediately productive in this repository.

1) Big picture
- Flutter mobile/web app in `lib/` that uses `go_router` for navigation and `provider` for DI/state.
- A minimal TypeScript backend stub lives in `backend/` exposing `/api/uploads/presign` and `/api/uploads/complete` used by the app.
- Photo upload flow: app -> `lib/api/api_client.dart` presign -> upload to Cloudinary (signed params) -> `complete` call to backend -> verification result.

2) Key files & directories (examples)
- `lib/main.dart` — app entry and ThemeData (Material, green primary).
- `lib/router.dart` — all app routes (initialLocation `/signup`). Use `go_router` when adding routes.
- `lib/api/api_client.dart` — central HTTP client. Note: emulator networking uses `http://10.0.2.2:3000/api`.
- `lib/models/` — domain models; `farm_model.dart` shows GeoJSON boundary expectations (coordinates are [lon, lat]).
- `lib/services/` — service wrappers (e.g., `farm_service.dart`) meant for server API integration.
- `lib/screens/` — UI screens and feature implementations (camera flow, claim flow).
- `backend/server.ts` — minimal stub used in local development and tests; responses are mocked.
- `pubspec.yaml` — dependencies include `go_router`, `provider`, `camera`, `flutter_map`, and `build_runner` for codegen.

3) Developer workflows the agent should use
- Install/update dependencies: `flutter pub get` (for Flutter) and `npm install` (inside `backend/`).
- Run app (dev): `flutter run` or use your IDE preview. For Android emulator the backend base must be `10.0.2.2`.
- Run backend stub (dev):
  - Build+start: `cd backend; npm run build; npm start` (uses compiled `dist/server.js`).
  - Quick dev: `cd backend; npx ts-node server.ts` (local dev without tsc output).
- Tests: `flutter test` (unit tests under `test/`). Tests use `mockito` and custom mocks in `test/`.
- Code generation: if you add codegen annotations, run `dart run build_runner build --delete-conflicting-outputs`.

4) Project-specific conventions & gotchas
- Network: Use `10.0.2.2:3000` from Android emulator to reach local backend; web uses `localhost`.
- GeoJSON ordering: `farm_model.dart` and `api_client.dart` use `[longitude, latitude]` (GeoJSON standard). Keep this when creating boundaries.
- Upload flow: `presignUpload` -> `uploadToCloudinary` -> `completeUpload`. See `lib/api/api_client.dart` and `backend/server.ts` for the mocked fields (publicId, uploadUrl, signature).
- Error handling: many API methods throw Exceptions on non-2xx; wrap calls in try/catch in UI or service layers and show user-friendly messages.
- Theme & styling: global theming is in `main.dart`; follow existing input decoration and color choices for UI consistency.
- Routes expecting extras: some routes assume `state.extra as Map<String, dynamic>` (see `router.dart` for examples). Preserve that shape when navigating.

5) When changing or adding features
- Add screens under `lib/screens/<feature>/` and register routes in `lib/router.dart`.
- For API hooks, extend `lib/api/api_client.dart` or add a service in `lib/services/` and inject via `provider` at top-level if shared.
- For models, update `lib/models/` and keep JSON (de)serialization logic close to the model.

6) Quick examples (copyable)
- Call backend from emulator (API client already uses): `http://10.0.2.2:3000/api`
- Add dependency: `flutter pub add provider` (then `flutter pub get`).
- Run unit tests: `flutter test`.

7) Useful references inside repo
- `lib/api/api_client.dart` — upload + auth flows.
- `backend/server.ts` — stub responses and verification logic (useful for local integration tests).
- `pubspec.yaml` — dependency list and codegen dev deps.
- `GEMINI.md` — longer AI-focused guidelines and environment expectations (reference, not authoritative).

8) Safety & environment notes
- Do not hardcode real API keys or Cloudinary secrets — the backend stub includes mock secrets for local dev only.
- If you add external credentials, prefer environment variables or secret managers and document them in `README.md`.

If anything above is unclear or you want more details (CI commands, emulator/device tips, or automated test setup), tell me which area to expand.
