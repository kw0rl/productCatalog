# Product Catalog

A Flutter product catalog app built for the Neurogine mobile developer assessment. The app retrieves product data from DummyJSON and displays it in a two-column grid.

**Status:** The required product list, pagination, product details, request states, and debounced search are implemented. The image loading placeholder and error handling bonus is also implemented. Remaining optional improvements and validation notes are listed below.

## Tech Stack

- Flutter and Dart
- Material widgets for the UI
- `http` for API requests
- `dart:convert` for JSON decoding

## Getting Started

### Prerequisites

- Flutter SDK with a Dart version compatible with `^3.13.2`, as specified in `pubspec.yaml`
- An Android emulator or connected Android device with USB debugging enabled
- Internet access to retrieve product data and images
- Enough free storage on the device or emulator to install the app

### Run the App

```sh
git clone https://github.com/kw0rl/productCatalog.git
cd productCatalog
flutter pub get
flutter run
```

If the project is already downloaded, run the last two commands from the project directory. If multiple devices are connected, use `flutter devices` to find the target device, then run `flutter run -d <device-id>`.

To run static analysis:

```sh
flutter analyze
```

## Current Features

- Product grid showing a thumbnail, title, and price
- Loading indicator while the initial request is pending
- Error message with a Retry button when the initial request fails
- Empty-state message when no products are returned
- Product cards when the request succeeds
- Scroll-based pagination, requesting up to 20 products per page
- Loading indicator below the grid while the next page is being fetched
- Error message and Retry button for failed additional-page requests, while keeping existing products visible
- Guards against overlapping page requests for the active search and further requests after the final page is detected
- Tap a product to open its detail screen with title, description, price, rating, and all product images arranged vertically
- Loading and error states with Retry on the detail screen
- API-based search with a 400 ms debounce, paginated results, and an empty state
- Clearing the search input restores the unfiltered catalog
- Image loading spinners and broken-image icons for failed images on both catalog cards and the detail screen

## Code Organization

```text
lib/
  main.dart                     App setup, catalog screen, and UI state
  product_model/
    product.dart                Product fields and JSON-to-model conversion
  services/
    product_service.dart        HTTP request and response handling
  screens/
    product_detail_screen.dart  Product details, loading, and retry
```

The code separates data responsibilities from the UI:

- **Data:** `ProductService` retrieves and decodes JSON for list, search, and detail requests. It returns a `List<Product>` for list/search requests and a single `Product` for details. The model converts individual JSON objects into product instances.
- **UI:** `CatalogScreen` stores the accumulated products, loading flag, error message, and whether more products can be requested. It uses `setState` to update the display and a `ScrollController` to detect when the user approaches the bottom of the grid.
- **Detail UI:** `ProductDetailScreen` receives the selected product ID through navigation. It starts a detail request in `initState` and uses `FutureBuilder<Product>` to display its result. Retry replaces the stored Future with a new request.

This separation keeps HTTP and JSON handling out of the widget code. The screen uses Flutter's built-in `StatefulWidget` and `setState` without an additional state-management package. Keeping an accumulated list lets new pages be appended without replacing products already on screen. App setup and the catalog UI currently remain together in `main.dart`.

## API Usage

The first request is `GET https://dummyjson.com/products?limit=20&skip=0`. No API key is required. Subsequent requests use the number of products already loaded as `skip`.

List and search responses contain a `products` array. Each entry is converted to a `Product` containing `id`, `title`, `price`, `thumbnail`, `description`, `rating`, and `images`. Non-200 responses throw an exception, which the UI displays as an error.

Details use `GET https://dummyjson.com/products/{id}` and convert the response directly into one product.

When less than 300 logical pixels of content remain below the visible area, the scroll listener attempts to load another page. A loading flag prevents overlapping requests. Successful responses are appended to the existing list; failed requests leave that list unchanged so a retry uses the same offset.

The screen assumes a page size of 20 and stops requesting pages when a response contains fewer than 20 products. It does not currently use the API's `total` field. If the final page contains exactly 20 products, one additional request is needed to detect the end.

## Search Approach

Search uses the API endpoint `/products/search` with `q`, `limit`, and `skip` parameters. API-based search was chosen because filtering only the products already loaded on the device could miss matching products on later pages.

A `Timer` waits 400 ms after the last input change before applying a new search. Each input change cancels the previous timer. Leading and trailing whitespace is removed, and an unchanged trimmed query does not restart the search. `Uri.https` encodes the query parameters.

When a new query becomes active, the accumulated list is cleared and pagination starts again at `skip=0`. Further page requests and retries use that active query. Clearing the input switches back to the regular list endpoint.

A search version counter prevents responses and errors from older searches from updating the current results or loading state. Existing network requests are not cancelled; their results are ignored once their version is no longer current. The timer and scroll controller are disposed when the catalog screen is removed.

## Image Loading and Error Handling

Both screens use `Image.network` with `loadingBuilder` to display a spinner while image data is loading and return the image widget when loading completes. An `errorBuilder` displays a broken-image icon if an image cannot be loaded, while the product text remains available.

Catalog image placeholders use the space allocated by the card's `Expanded` widget. Detail images, loading placeholders, and error placeholders all use a height of 200 logical pixels to keep the content below them from shifting between these states.

## Validation

Manual checks completed during development:

- The app runs on an Android phone and emulator.
- Scrolling loads additional products.
- An initial request failure can be retried after restoring internet access.
- A failed additional-page request keeps existing products visible and can be retried successfully.
- Product cards open the corresponding detail screen with text and images.
- The detail screen displays a centered error message and Retry button when the request fails.
- Search returns matching results, and a query with no matches displays the empty state.
- Search pagination, retry after restoring connectivity, clearing the query, and navigation from search results were manually checked.
- Image error fallbacks were checked on the catalog and detail screens using temporary invalid image URLs. The original URLs were restored afterward.
- The loading placeholder appearance was manually checked. To verify the full loading-to-image transition, use an uncached image on a slow connection; cached images or fast connections can make the spinner difficult to observe.

Before submission, also verify end-of-list behavior and rapid scrolling, and run `flutter analyze`. Automated tests have not yet been added.

## Feature Checklist and Remaining Work

### Required Features

- [x] Add a retry button to the error state.
- [x] Implement scroll-based pagination with `limit=20` and `skip`.
- [x] Add product navigation and a detail screen using the product detail endpoint.
- [x] Display description, price, rating, and images on the detail screen.
- [x] Add debounced search.
- [x] Document the chosen search approach and its rationale.

### Optional Improvements

- [ ] Pull-to-refresh
- [x] Image loading placeholders and image error handling
- [ ] A unit test for data or business logic

## AI Assistance Disclosure

ChatGPT/Codex was used to explain Dart and Flutter concepts, review code and errors, and compare progress against the assessment requirements. It provided step-by-step guidance and code examples for separating API access from UI code, retry handling, pagination state, scroll listeners, widget layout, detail navigation and fetching, API-based search, debounce timers, handling outdated search responses, and image loading/error builders. It also provided guidance on manually checking image placeholders and failures, plus Git and emulator troubleshooting.

Codex directly moved the existing `Product` model into `lib/product_model/product.dart`, removed the duplicate model definition from `main.dart`, and added the model import. It also completed the grid's `Column`/`Expanded` wrapper, added the conditional loading indicator below the grid, corrected the product card's `InkWell` nesting, and formatted `main.dart`. This README was drafted and updated by Codex after reviewing the source files.

This disclosure should be updated if further AI assistance is used during development.
