## Git & Release Workflow Rules (Trunk-Based Development)

> **Agent Instruction:** Strictly follow these Git, branching, and versioning rules for all tasks in this repository. 
> * **NO `develop` branch:** Always branch off `main`.
> * **NO Agent PRs or Direct Merges to `main`:** Do **not** create Pull Requests (e.g., via `gh pr create` or tools) and do **not** merge branches into `main` locally. The human developer handles all Pull Requests and Squash Merges manually on GitHub Web.

### 1. Branching Strategy

* **`main` (Permanent Trunk):** Single source of truth. Every commit on `main` must compile and pass `flutter analyze` and `flutter test`. Never commit directly to `main` during feature work.
* **`feat/<name>` (Temporary):** Branch off `main` for new features, screens, or state refactors.
* **`fix/<name>` (Temporary):** Branch off `main` for non-emergency bug fixes.
* **`chore/<name>` (Temporary):** Branch off `main` strictly for Flutter SDK upgrades, `pubspec.yaml` dependency updates, Gradle/AGP changes, or CocoaPods updates. **Never mix dependency/native build changes with feature code.**
* **`hotfix/<vX.Y.Z>` (Temporary - Emergency Only):** Branch off the live **Git Tag** (never `main`) only when a live store release crashes and `main` already has unreleased commits.

### 2. Task & Hand-Off Lifecycle

When starting, executing, and completing a task from the development plan:

1. **Start Task (Sync with `main` first):**
   Always ensure local `main` has the latest merged PRs from GitHub before branching:
   ```bash
   git checkout main && git pull origin main
   git checkout -b <feat|fix|chore>/<short-kebab-name>
   ```

2. **During Task:**
   * Commit logically on the working branch using Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`).
   * For multi-day features, hide incomplete UI/logic behind a constant boolean flag (`const bool kEnableFeatureX = false;`) so work can be merged into `main` incrementally.

3. **Pre-Push Verification (Mandatory):**
   Before finishing a task or pushing the branch, run:
   ```bash
   flutter analyze && flutter test
   ```
   *Do not push or mark the task ready if either command fails.*

4. **Complete Task (Push & Hand Off to Human for PR):**
   Once tests and analysis pass:
   * Mark the corresponding task as completed in `AGENTS.MD` and include it in the branch commit.
   * Push the working branch to `origin`:
     ```bash
     git push -u origin <branch-name>
     ```
   * **STOP HERE.** Provide the user with a concise PR title (following Conventional Commits, e.g., `feat: implement offline caching`) and a bulleted summary of changes so the user can open and Squash & Merge the Pull Request on GitHub Web.

5. **Post-PR Cleanup (When starting the next task):**
   Once the user merges the PR on GitHub Web, switch back to `main`, pull the squashed commit, and delete the local feature branch:
   ```bash
   git checkout main && git pull origin main
   git branch -d <previous-branch-name>
   ```

### 3. Store Releases & `pubspec.yaml` Versioning

Flutter versions use `version: X.Y.Z+N` (`X.Y.Z` = semver, `+N` = store build integer).

* **CRITICAL RULE:** The build number `+N` must strictly increment by at least `+1` for every store upload. Never reuse or decrement `+N`.

**To cut a release from `main` (only when explicitly instructed by the user):**

1. Checkout `main`, pull latest (`git pull origin main`), and verify `flutter analyze` and `flutter test` pass.
2. Bump `version: X.Y.Z+N` in `pubspec.yaml` and update `CHANGELOG.md` (either via a `chore/release-vX.Y.Z` PR or directly on `main` if instructed by the user).
3. Once the version bump is on `main`, tag that exact commit and push the tag:
   ```bash
   git checkout main && git pull origin main
   git tag -a vX.Y.Z+N -m "Release vX.Y.Z (Build N)"
   git push origin vX.Y.Z+N
   ```
4. Build release artifacts from the tag (`flutter build appbundle --release` / `flutter build ipa --release`).

### 4. Emergency Store Hotfix Flow

If live store release `vX.Y.Z+N` needs an urgent fix while `main` contains unreleased work:

1. Branch from the **Git Tag**: `git checkout -b hotfix/X.Y.Z+1 vX.Y.Z+N`
2. Fix the bug and bump `pubspec.yaml` to `X.Y.(Z+1)+(N+1)`.
3. Verify with `flutter analyze && flutter test`, commit, tag (`vX.Y.(Z+1)+(N+1)`), push the tag, and build the hotfix release.
4. Create a `fix/port-hotfix-X.Y.Z+1` branch off `main`, cherry-pick the fix commit, and update `main`'s `pubspec.yaml` build number `+N` so the next `main` release is strictly higher than the hotfix build number. Push this branch so the user can PR it into `main` on GitHub Web.

### 5. Flutter Guardrails

* **Always commit `pubspec.lock`:** Never ignore `pubspec.lock` so historical tags always reproduce exact dependency versions.
* **Sync with Development Plan:** Update task checkboxes in `AGENTS.MD` on the feature branch *before* pushing to `origin` so the roadmap update is included in the user's GitHub PR.