import 'package:flutter/material.dart';

import '../models/product.dart';

const products = [
  Product(
    id: 'headphones',
    title: 'Studio Headphones',
    subtitle: 'A little less world. A little more you.',
    description: 'Find your own quiet. Rich, balanced sound meets a soft, considered fit. Studio is made for focused mornings, long journeys and the songs you keep coming back to.',
    image: 'assets/photos/headphones.jpg',
    priceCents: 24900,
    category: 'Audio',
    rating: 4.9,
    tags: ['Wireless', 'Noise cancelling', '40-hour battery'],
    variants: [
      ProductVariant('sage', 'Sage', Color(0xFF9BA48B), 8),
      ProductVariant('sand', 'Sand', Color(0xFFD8CEBB), 3),
      ProductVariant('ink', 'Ink', Color(0xFF343D37), 0),
    ],
    specs: {
      'Listening time': 'Up to 40 hours',
      'Connection': 'Bluetooth 5.3 / USB-C',
      'Weight': '245 g',
      'In the box': 'Headphones, case, charging cable',
    },
  ),
  Product(
    id: 'camera',
    title: 'Focus Camera',
    subtitle: 'Keep the little moments.',
    description: 'An everyday companion for your own way of seeing. A bright prime lens, intuitive controls and a small footprint let you spend less time adjusting and more time discovering.',
    image: 'assets/photos/camera.jpg',
    priceCents: 69900,
    category: 'Photography',
    rating: 4.8,
    tags: ['24 MP', 'Compact', '4K video'],
    variants: [
      ProductVariant('graphite', 'Graphite', Color(0xFF414640), 5),
      ProductVariant('silver', 'Silver', Color(0xFFBBC0B7), 2),
    ],
    specs: {
      'Sensor': '24 megapixels',
      'Video': '4K at 30 fps',
      'Weight': '385 g',
      'In the box': 'Camera, strap, battery, USB-C cable',
    },
  ),
  Product(
    id: 'speaker',
    title: 'Room Speaker',
    subtitle: 'Good sound. Wherever you are.',
    description: 'Small footprint, room-filling sound. Warm bass and clear vocals in a tactile fabric finish. Carry a little atmosphere from a slow morning at home to an evening with friends.',
    image: 'assets/photos/speaker.jpg',
    priceCents: 12900,
    category: 'Audio',
    rating: 4.7,
    tags: ['Portable', 'Bluetooth', 'Water resistant'],
    variants: [
      ProductVariant('charcoal', 'Charcoal', Color(0xFF50564F), 12),
      ProductVariant('olive', 'Olive', Color(0xFF848E70), 4),
    ],
    specs: {
      'Listening time': 'Up to 18 hours',
      'Protection': 'IPX5 splash resistant',
      'Weight': '620 g',
      'In the box': 'Speaker, USB-C cable',
    },
  ),
  Product(
    id: 'watch',
    title: 'Everyday Watch',
    subtitle: 'Make a little time for yourself.',
    description: 'Clean lines, a quiet dial and a comfortable everyday strap. A considered timepiece that brings a gentler rhythm to a busy day. An essential you will reach for again and again.',
    image: 'assets/photos/watch.jpg',
    priceCents: 15900,
    category: 'Lifestyle',
    rating: 4.9,
    tags: ['Minimal dial', 'Quartz', '2-year warranty'],
    variants: [
      ProductVariant('taupe', 'Taupe', Color(0xFFADA091), 7),
      ProductVariant('black', 'Black', Color(0xFF323630), 2),
    ],
    specs: {
      'Case': '38 mm brushed steel',
      'Movement': 'Quartz',
      'Strap': '20 mm, interchangeable',
      'In the box': 'Watch, presentation box',
    },
  ),
];
// A generated arrival has a deterministic identity, so saved carts and favorites
// can resolve it even after it is removed from the visible catalog or restarted.
Product arrivalProduct(int number) {
  if (number < 1) throw const FormatException('Invalid arrival number');
  final base = products[(number - 1) % products.length];
  return Product(
    id: 'arrival-$number',
    title: '${base.title} · Edit $number',
    subtitle: 'Fresh in the collection. A new everyday favorite.',
    description: base.description,
    image: base.image,
    priceCents: base.priceCents + number % 5 * 500,
    category: base.category,
    rating: base.rating,
    tags: ['New arrival', ...base.tags],
    variants: base.variants,
    specs: base.specs,
  );
}

Product productById(String id) {
  if (id.startsWith('arrival-')) {
    final number = int.tryParse(id.substring(8));
    if (number == null || id != 'arrival-$number') {
      throw const FormatException('Invalid arrival ID');
    }
    return arrivalProduct(number);
  }
  return products.firstWhere((p) => p.id == id);
}

ProductVariant variantById(Product p, String id) =>
    p.variants.firstWhere((v) => v.id == id);
List<Product> filterProducts({
  Iterable<Product> source = products,
  String query = '',
  String category = 'All',
  String sort = 'Curated',
}) {
  final result = source
      .where(
        (p) =>
            (category == 'All' || p.category == category) &&
            '${p.title} ${p.category} ${p.tags.join(' ')}'
                .toLowerCase()
                .contains(query.trim().toLowerCase()),
      )
      .toList();
  if (sort == 'Price: low to high') {
    result.sort((a, b) => a.priceCents.compareTo(b.priceCents));
  }
  if (sort == 'Price: high to low') {
    result.sort((a, b) => b.priceCents.compareTo(a.priceCents));
  }
  if (sort == 'Top rated') result.sort((a, b) => b.rating.compareTo(a.rating));
  return result;
}
