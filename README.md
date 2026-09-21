# Product Catalog

A Flutter product catalog app built for the Neurogine mobile developer assessment. The app retrieves product data from DummyJSON and displays it in a two-column grid.

**Status:** Work in progress. The product list, scroll-based pagination, loading states, and retry handling are implemented. Product details and search are still pending.

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
- Guards against overlapping requests and further requests after the final page is detected

## Code Organization

```text
lib/
  main.dart                     App setup, catalog screen, and UI state
  product_model/
    product.dart                Product fields and JSON-to-model conversion
  services/
    product_service.dart        HTTP request and response handling
```

The code separates data responsibilities from the UI:

- **Data:** `ProductService` retrieves the response, decodes JSON, and returns a `List<Product>`. The `Product` model defines the product fields and converts individual JSON objects into model instances.
- **UI:** `CatalogScreen` stores the accumulated products, loading flag, error message, and whether more products can be requested. It uses `setState` to update the display and a `ScrollController` to detect when the user approaches the bottom of the grid.

This separation keeps HTTP and JSON handling out of the widget code. The screen uses Flutter's built-in `StatefulWidget` and `setState` without an additional state-management package. Keeping an accumulated list lets new pages be appended without replacing products already on screen. App setup and the catalog UI currently remain together in `main.dart`.

## API Usage

The first request is `GET https://dummyjson.com/products?limit=20&skip=0`. No API key is required. Subsequent requests use the number of products already loaded as `skip`.

It reads the `products` array and maps each entry to a `Product` containing `id`, `title`, `price`, and `thumbnail`. Non-200 responses throw an exception, which the UI displays as an error.

When less than 300 logical pixels of content remain below the visible area, the scroll listener attempts to load another page. A loading flag prevents overlapping requests. Successful responses are appended to the existing list; failed requests leave that list unchanged so a retry uses the same offset.

The screen assumes a page size of 20 and stops requesting pages when a response contains fewer than 20 products. It does not currently use the API's `total` field. If the final page contains exactly 20 products, one additional request is needed to detect the end.

## Validation

Manual checks completed during development:

- The app runs on an Android phone and emulator.
- Scrolling loads additional products.
- An initial request failure can be retried after restoring internet access.
- A failed additional-page request keeps existing products visible and can be retried successfully.

Before submission, also verify end-of-list behavior and rapid scrolling, and run `flutter analyze`. Automated tests have not yet been added.

## Remaining Work

### Required Features

- [x] Add a retry button to the error state.
- [x] Implement scroll-based pagination with `limit=20` and `skip`.
- [ ] Add product navigation and a detail screen using the product detail endpoint.
- [ ] Display description, price, rating, and images on the detail screen.
- [ ] Add debounced search.
- [ ] Document the chosen search approach and its rationale once implemented.

### Optional Improvements

- [ ] Pull-to-refresh
- [ ] Image loading placeholders and image error handling
- [ ] A unit test for data or business logic

## AI Assistance Disclosure

ChatGPT/Codex was used to explain Dart and Flutter concepts, review code and errors, and compare progress against the assessment requirements. It provided step-by-step guidance and code examples for separating API access from UI code, retry handling, pagination state, scroll listeners, and widget layout. It also provided Git and emulator troubleshooting guidance.

Codex directly moved the existing `Product` model into `lib/product_model/product.dart`, removed the duplicate model definition from `main.dart`, and added the model import. It also completed the grid's `Column`/`Expanded` wrapper, added the conditional loading indicator below the grid, and formatted `main.dart`. This README was drafted and updated by Codex after reviewing the source files.

This disclosure should be updated if further AI assistance is used during development.
