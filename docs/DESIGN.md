# NOVA design notes

The visual direction is an editorial store for considered everyday objects. A warm off-white canvas, forest-green text, pale sage surfaces, quiet borders and generous space give product photography room to breathe. Dark mode uses deep green surfaces and a pale lime action color.

## Layout and type

- Main rhythm: 8 / 16 / 24 / 32 px; 24 px page gutters, 1120 px content ceiling.
- Cards: 20–28 px corners, flat surfaces and subtle borders. No decorative shadow stack.
- Roboto is bundled locally at regular, medium and bold weights.
- Small uppercase labels establish hierarchy; large headings use tighter tracking.
- Content grows vertically. Product grids adapt their column count; details switch to two columns when space allows. Large text reduces grid density.
- Bottom actions use SafeArea, Row and Expanded; the body scrolls independently.
- The separate ComponentGallery widget is exercised by the capture test; it is kept out of the shopping flow.

## Motion

| Interaction | Behavior |
| --- | --- |
| Screen entry | 550 ms ease-out fade with 18 px vertical travel |
| Navigation | 380 ms forward / 280 ms back fade and short horizontal slide |
| Product image | Hero transition from catalog to detail |
| Tab selection | 300 ms fade; IndexedStack preserves each tab's state |
| Bookmark | 220 ms scale/fade between states plus selection haptic |
| Primary action | 130 ms press scale to 97.5% |
| Add to bag | Animated label/icon confirmation, bag badge, haptic and SnackBar |
| Receipt | Finite ease-out-back confirmation reveal |

Custom animation durations become zero when MediaQuery.disableAnimations is enabled. There are no looping decorative animations. Material controls retain their native interaction behavior.

## Honest states

Search and favorites have actionable empty states. Sold-out finishes disable Add to Cart. Bag quantities cannot exceed remaining local stock. Registration displays field-specific errors and enforces consent. Storage failures leave in-memory state usable and expose Retry. Checkout and receipts explicitly identify demo orders.

Photos show the signature finish; variant selection does not fake a new photograph. Local profiles do not imply server authentication. Prices and editorial ratings are illustrative.

## Verification

The automated layout matrix covers 11 screens at six viewport sizes with normal and doubled text. Form error/keyboard layouts and pinned action positions are checked separately within that matrix. Screenshot fixtures cover light, dark and enlarged text, plus a wide detail layout. Screenshots prefixed emulator- come from the Android device; the other PNGs are Flutter component renders.

All application classes remain in main.dart for the requested single-file submission. They have explicit model/state/component/screen boundaries so later course milestones can move them into separate folders.
