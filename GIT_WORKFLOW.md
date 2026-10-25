## Git & Release Workflow Rules (Trunk-Based Development)

> **Agent Instruction:** Strictly follow these Git, branching, and versioning rules for all tasks in this repository. Do **not** create or use a `develop` branch.

### 1. Branching Strategy
* **`main` (Permanent Trunk):** Single source of truth. Every commit on `main` must compile and pass `flutter analyze` and `flutter test`. Never commit multi-file features directly to `main`.
* **`feat/<name>` (Temporary):** Branch off `main` for new features, screens, or state refactors.
* **`fix/<name>` (Temporary):** Branch off `main` for non-emergency bug fixes.
* **`chore/<name>` (Temporary):** Branch off `main` strictly for Flutter SDK upgrades, `pubspec.yaml` dependency updates, Gradle/AGP changes, or CocoaPods updates. **Never mix dependency/native build changes with feature code.**
* **`hotfix/<vX.Y.Z>` (Temporary - Emergency Only):** Branch off the live **Git Tag** (never `main`) only when a live store release crashes and `main` already has unreleased commits.

### 2. Task & Merge Lifecycle
When starting, executing, and completing a task from the development plan:

1. **Start Task:**
   ```bash
   git checkout main && git pull origin main
   git checkout -b <feat|fix|chore>/<short-kebab-name>
   ```
2. **During Task:**
   * Commit frequently on the working branch (`wip` commits are fine).
   * For multi-day features, hide incomplete UI/logic behind a constant boolean flag (`const bool kEnableFeatureX = false;`) so work can be merged into `main` incrementally.
3. **Pre-Merge Check (Mandatory):**
   ```bash
   flutter analyze && flutter test
   ```
   *Do not merge into `main` if either command fails.*
4. **Complete Task (Squash & Merge into `main`):**
   Always squash feature branches into a single atomic commit on `main` using Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`):
   ```bash
   git checkout main
   git merge --squash <branch-name>
   git commit -m "<type>: <concise summary of completed task>"
   git push origin main
   git branch -d <branch-name>
   ```

### 3. Store Releases & `pubspec.yaml` Versioning
Flutter versions use `version: X.Y.Z+N` (`X.Y.Z` = semver, `+N` = store build integer).
* **CRITICAL RULE:** The build number `+N` must strictly increment by at least `+1` for every store upload. Never reuse or decrement `+N`.

**To cut a release from `main`:**
1. Verify `flutter analyze` and `flutter test` pass on `main`.
2. Bump `version: X.Y.Z+N` in `pubspec.yaml` and update `CHANGELOG.md`.
3. Commit and tag the exact version on `main`:
   ```bash
   git add pubspec.yaml CHANGELOG.md
   git commit -m "chore(release): vX.Y.Z+N"
   git tag -a vX.Y.Z+N -m "Release vX.Y.Z (Build N)"
   git push origin main --tags
   ```
4. Build release artifacts from the tag (`flutter build appbundle --release` / `flutter build ipa --release`).

### 4. Emergency Store Hotfix Flow
If live store release `vX.Y.Z+N` needs an urgent fix while `main` contains unreleased work:
1. Branch from the **Git Tag**: `git checkout -b hotfix/X.Y.Z+1 vX.Y.Z+N`
2. Fix the bug and bump `pubspec.yaml` to `X.Y.(Z+1)+(N+1)`.
3. Commit, tag (`vX.Y.(Z+1)+(N+1)`), push tags, and build the release.
4. Checkout `main`, cherry-pick the fix commit, and update `main`'s `pubspec.yaml` build number `+N` so the next `main` release is strictly higher than the hotfix build number.
5. Delete the hotfix branch: `git branch -D hotfix/X.Y.Z+1`.

### 5. Flutter Guardrails
* **Always commit `pubspec.lock`:** Never ignore `pubspec.lock` so historical tags always reproduce exact dependency versions.
* **Sync with Development Plan:** When a feature branch is squash-merged into `main`, mark the corresponding task as completed in `AGENTS.MD`.