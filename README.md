# Dynamic Form Builder (iOS)

A SwiftUI iOS app that renders a **fully dynamic form** from a JSON definition bundled in the app. The form layout, field types, validation rules, and visual theme are all driven by `form.json`—no hard-coded screens per form.

This repository is a **take-home exercise** submission for Eulerity. It demonstrates JSON-driven UI, a small MVVM architecture, and support for multiple input types with theming and validation.

---

## What it does

1. Loads `form.json` from the app bundle at launch.
2. Renders fields in **order** (via each field’s `order` property).
3. Applies **theme colors** (background, text, borders, errors, buttons) from JSON.
4. Collects user input into an in-memory dictionary keyed by field `id`.
5. On **Save**, runs validation and shows an alert with the submitted values if everything passes.

You can change the form (add/remove fields, colors, labels) by editing `form.json` and rebuilding—no Swift changes required for supported field types.

---

## Requirements

- **Xcode** 15+ (project uses SwiftUI and modern Xcode project format)
- **iOS** simulator or device (SwiftUI app target: `TakeHomeExerciseProject`)
- macOS for development

---

## How to run

1. Open `TakeHomeExerciseProject.xcodeproj` in Xcode.
2. Select the **TakeHomeExerciseProject** scheme and an iOS simulator.
3. Press **Run** (⌘R).

The app opens directly on the dynamic form screen (`FormScreenView`). There is no login or navigation stack—single-screen flow.

To try a different form, edit `TakeHomeExerciseProject/form.json` and run again.

---

## Architecture overview

The app follows a simple **MVVM** pattern:

```
form.json  →  FormLoader  →  FormViewModel  →  FormScreenView
                                    ↓              ↓
                              validation      DynamicFieldView (per field)
```

| Layer | File(s) | Responsibility |
|--------|---------|----------------|
| **Data** | `form.json` | Form definition: theme, title, fields |
| **Model** | `Models.swift` | `Codable` types matching JSON (`FormPayload`, `Field`, `Theme`, etc.) |
| **Loading** | `FormLoader.swift` | Reads and decodes `form.json` from the bundle |
| **ViewModel** | `FormViewModel.swift` | Field values, validation, save/submit logic |
| **Views** | `FormScreenView.swift`, `DynamicFieldView.swift` | Layout, theming, and per-type controls |
| **Utilities** | `HexColor.swift` | Parses `#RRGGBB` / `RRGGBB` strings into SwiftUI `Color` |
| **App entry** | `TakeHomeExerciseProjectApp.swift` | Launches `FormScreenView` |

`ContentView.swift` is unused template code from the Xcode project scaffold; the real UI starts in `FormScreenView`.

---

## Data flow (step by step)

### 1. Load JSON (`FormLoader`)

- Looks up `form.json` in the main bundle.
- Decodes it into `FormPayload` using `JSONDecoder`.
- If the file is missing, the app **crashes** with `fatalError` (intentional for a missing required asset).
- If decoding fails, it logs the error and returns an **empty** payload (empty title, no fields) so the UI shows “No Form Exist” instead of crashing.

### 2. Initialize state (`FormViewModel`)

- Stores the decoded `payload`.
- Pre-fills `values` from any field `default_values` in JSON (e.g. multi-select dropdown defaults).
- Exposes `sortedFields`: fields sorted by `order` ascending.

### 3. Render UI (`FormScreenView` + `DynamicFieldView`)

- Shows `form_title` and each field with a non-`nil` `type`.
- Optional **section title** (`field.title`) appears above the control when non-empty.
- Binds each field to `viewModel.values[field.id]` via a custom `Binding<Any?>`.
- Shows per-field **error messages** under the control when validation fails.
- **Save** calls `viewModel.save()`.

### 4. Validate and submit (`FormViewModel.save`)

- `validate()` clears previous errors, then for each field:
  - **Required**: checks non-empty string, non-empty multi-select array, or `true` for booleans (toggle/checkbox).
  - **URI subtype**: string must contain `"http"` (simple URL check).
- If valid: sets `output` to a string description of `values`, sets `showAlert = true`.
- If invalid: errors appear inline on the affected fields; no alert.

---

## JSON schema

Top-level structure:

```json
{
  "theme": { ... },
  "form_title": "About Yourself",
  "fields": [ ... ]
}
```

### Theme

| JSON key | Model property | Used for |
|----------|----------------|----------|
| `background_color` | `backgroundColor` | Screen background |
| `text_color` | `textColor` | Titles, labels, field text |
| `clickable_text_color` | `clickableTextColor` | Checkbox link text |
| `border_color` | `borderColor` | Text fields, dropdown outline |
| `error_color` | `errorColor` | Validation messages, over-limit counter |
| `button_color` | `buttonColor` | Save button tint |

Colors are hex strings (with or without `#`); see `HexColor.swift`.

### Field (common properties)

| Property | Description |
|----------|-------------|
| `id` | Unique key for stored value and errors |
| `order` | Display order (lower = higher on screen) |
| `type` | `TEXT`, `DROPDOWN`, `TOGGLE`, `CHECKBOX`, or unknown (e.g. `DATE_PICKER`) |
| `title` | Optional heading above the control |
| `label` | Control label (toggle, checkbox, dropdown prompt context) |
| `placeholder` | Hint text for text inputs |
| `max_length` | Max characters; enforced in UI with live counter |
| `error_message` | Shown when required validation fails |
| `required` | If `true`, field must have a value on save |
| `allow_multiple` | For `DROPDOWN`: multi-select vs single |
| `default_values` | Initial value(s)—`[String]` for multi-dropdown |
| `options` | `{ "id", "label" }[]` for dropdowns |
| `link` | Optional URL for checkbox label (`Link` in SwiftUI) |

Text-only:

| Property | Values |
|----------|--------|
| `subtype` | `PLAIN`, `MULTILINE`, `NUMBER`, `URI`, `SECURE` |

---

## Supported field types

### `TEXT`

Rendered by `DynamicFieldView.textFieldView` based on `subtype`:

| Subtype | Control | Notes |
|---------|---------|--------|
| `PLAIN` | `TextField` | Default keyboard |
| `MULTILINE` | `TextEditor` with placeholder overlay | Taller box (~100pt) |
| `NUMBER` | `TextField` | `.numberPad` keyboard |
| `URI` | `TextField` | `.URL` keyboard; save validates contains `http` |
| `SECURE` | `SecureField` | Masked input |

When `max_length` is set, input is truncated and a **character counter** (`current/max`) is shown; counter turns error color if over limit (truncation normally prevents exceeding max).

### `DROPDOWN`

- Custom expandable list (not native `Picker`).
- **Single select** (`allow_multiple: false`): stores selected option `id` as `String`.
- **Multi select** (`allow_multiple: true`): stores `[String]` of option ids; tap toggles checkmarks.

### `TOGGLE`

- Native `Toggle` bound to `Bool`.

### `CHECKBOX`

- Custom square + checkmark tap target.
- If `link` is a valid URL, `label` is a tappable `Link`; otherwise plain text.

### Unknown types (e.g. `DATE_PICKER`)

- Decoded as `FieldType.unknown("DATE_PICKER")`.
- `DynamicFieldView` renders **nothing** for `.unknown` (no crash).
- Fields still appear in the list if `type != nil`; section title may show with no control—extend `DynamicFieldView` to add new types.

---

## Project structure

```
Eulerity_Mohd_TestProject/
├── README.md
├── TakeHomeExerciseProject.xcodeproj/
└── TakeHomeExerciseProject/
    ├── TakeHomeExerciseProjectApp.swift   # @main entry
    ├── FormScreenView.swift               # Main form screen
    ├── DynamicFieldView.swift             # Per-field UI by type
    ├── FormViewModel.swift                # State + validation
    ├── FormLoader.swift                   # Bundle JSON loader
    ├── Models.swift                       # Codable models
    ├── HexColor.swift                     # Theme color parsing
    ├── form.json                          # Form + theme definition
    └── Assets.xcassets/                   # App icon, accent color
├── TakeHomeExerciseProjectTests/          # Unit tests
└── TakeHomeExerciseProjectUITests/        # UI test scaffold
```

---

## Example form

The bundled `form.json` defines an **“About Yourself”** form with:

- Full name (required text, max 30)
- Phone number (required number, max 10)
- SMS consent toggle
- Gender dropdown (required, single)
- Portfolio URL (optional URI)
- Skills dropdown (required, multi)
- Bio (multiline, max 250)
- Password (required secure)
- Terms checkbox with link (required)
- A `DATE_PICKER` field to demonstrate **graceful handling of unsupported types**

---

## Testing

Unit tests live in `TakeHomeExerciseProjectTests`:

- **`testFieldParsing`** — loads bundle JSON (expects title/field count; update assertions if you change `form.json`).
- **`testUnknownTypeDoesNotCrash`** — decodes inline JSON with `DATE_PICKER` and ensures parsing does not crash.

Run tests in Xcode: **Product → Test** (⌘U).

---

## Design decisions and tradeoffs

- **`[String: Any]` for values** — One dictionary holds strings, bools, and string arrays for different field types. Simple for a take-home; a production app might use an enum or typed model per field.
- **JSON in bundle only** — No network fetch; keeps the exercise focused on rendering and validation.
- **Custom dropdown** — Full control over multi-select UX and theming vs. system `Picker`.
- **Lenient unknown types** — New JSON `type` values decode as `.unknown` and render empty UI instead of failing decode.
- **URI validation** — Minimal (`contains("http")`), not full `URL` validation.

---

## Possible extensions

- Implement `DATE_PICKER` (and other types) in `DynamicFieldView` + `FieldType`.
- Load form from remote API with caching.
- Strongly typed field values instead of `Any`.
- Accessibility identifiers and VoiceOver labels from JSON metadata.
- Snapshot / UI tests for each field type.

---

## Author

Mohd Naqvi — Eulerity take-home exercise submission.
