# Каталог и жесты — проверка всех требований

## 1. List и Grid — 3 балла

- [x] `ListView.separated` с ленивым `itemBuilder` и `separatorBuilder`.
- [x] `GridView.builder` с `crossAxisCount: 2` и рассчитанным `childAspectRatio`.
- [x] Одни и те же товары в обоих режимах: фото, название, category tag, звезда/рейтинг, цена.
- [x] Переключение кнопкой в AppBar, сохранение коллекции и позиции прокрутки каждого режима.

Код: [FeedScreen](../lib/screens/feed_screen.dart), [CatalogTile](../lib/widgets/catalog_tile.dart), [RootScreen](../lib/screens/root_screen.dart).

## 2. Pull-to-refresh — 2 балла

- [x] `RefreshIndicator` в обоих режимах и пустом состоянии.
- [x] `AlwaysScrollableScrollPhysics` работает даже с одним товаром.
- [x] `await Future.delayed(const Duration(milliseconds: 1500))`.
- [x] `insert(0, ...)` и `setState()` после ожидания.
- [x] Уникальный ID каждого поступления, защита от двух одновременных запросов и проверка `mounted` после await.

После обновления фильтры сбрасываются: добавленный товар сразу виден первым. Новые данные моделируются локально; реального API пока нет.

## 3. Удаление и UNDO — 3 балла

- [x] Каждый элемент обёрнут в `Dismissible(key: ValueKey(product.id))`.
- [x] `DismissDirection.endToStart`: справа налево в англоязычном интерфейсе.
- [x] Красный фон с `Icons.delete` появляется при свайпе.
- [x] `onDismissed` удаляет товар и показывает `SnackBarAction(label: 'UNDO')`.
- [x] UNDO вставляет исходный объект по сохранённому индексу внутри `setState()`.
- [x] При поиске запоминается индекс исходной коллекции, а не отфильтрованной выдачи.

## 4. Empty State

- [x] Иконка и точный текст **Catalog is Empty**.
- [x] **Restore catalog** восстанавливает первоначальные четыре товара.
- [x] Pull-to-refresh работает и здесь.
- [x] Пустой результат поиска отличается от пустого каталога: **No matching objects**, кнопка сброса фильтров.

## 5. Архитектура и защита — 2 балла

- [x] Модели — `lib/models`, интерфейс — `lib/screens`, компоненты — `lib/widgets`.
- [x] Отдельные `data`, `state`, `core`; небольшой файл запуска `main.dart`.
- [x] Подготовлены сценарий демонстрации и ответы на вопросы: [DEFENSE.md](DEFENSE.md).
- [ ] Студент проводит live demo и лично отвечает на вопрос преподавателя.

## Проверки

`test/catalog_test.dart` проверяет реальные свайпы, задержку 1500 мс, обе коллекции builders, сохранение данных, UNDO, empty/reset и 10 сочетаний размера экрана/масштаба текста в сетке. `test/widget_test.dart` сохраняет 18 проверок предыдущих лабораторных. Скриншоты экспортируются через `test/demo_capture_test.dart`.
