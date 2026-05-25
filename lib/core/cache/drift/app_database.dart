import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ── Tables ─────────────────────────────────────────────────────────────────────

@DataClassName('NotificationRow')
class NotificationsTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get type => text()();
  TextColumn get dataJson => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get deepLink => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();
  BoolColumn get isRead =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get groupKey => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── DAOs ───────────────────────────────────────────────────────────────────────

@DriftAccessor(tables: [NotificationsTable])
class NotificationsDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsDaoMixin {
  NotificationsDao(super.db);

  Future<void> upsert(NotificationRowCompanion entry) =>
      into(notificationsTable).insertOnConflictUpdate(entry);

  Future<List<NotificationRow>> getPage({
    required int page,
    required int perPage,
    List<String>? typeFilters,
    bool? unreadOnly,
  }) {
    final query = select(notificationsTable)
      ..where((n) => n.isDeleted.equals(false))
      ..orderBy([(n) => OrderingTerm.desc(n.receivedAt)])
      ..limit(perPage, offset: (page - 1) * perPage);

    if (unreadOnly == true) {
      query.where((n) => n.isRead.equals(false));
    }
    if (typeFilters != null && typeFilters.isNotEmpty) {
      query.where((n) => n.type.isIn(typeFilters));
    }
    return query.get();
  }

  Stream<List<NotificationRow>> watchPage({
    required int limit,
    List<String>? typeFilters,
    bool? unreadOnly,
  }) {
    final query = select(notificationsTable)
      ..where((n) => n.isDeleted.equals(false))
      ..orderBy([(n) => OrderingTerm.desc(n.receivedAt)])
      ..limit(limit);

    if (unreadOnly == true) {
      query.where((n) => n.isRead.equals(false));
    }
    if (typeFilters != null && typeFilters.isNotEmpty) {
      query.where((n) => n.type.isIn(typeFilters));
    }
    return query.watch();
  }

  Stream<int> watchUnreadCount() {
    final countExp = notificationsTable.id.count();
    return (selectOnly(notificationsTable)
          ..addColumns([countExp])
          ..where(notificationsTable.isRead.equals(false) &
              notificationsTable.isDeleted.equals(false)))
        .map((row) => row.read(countExp) ?? 0)
        .watchSingle();
  }

  Future<int> getTotalCount({
    List<String>? typeFilters,
    bool? unreadOnly,
  }) {
    final countExp = notificationsTable.id.count();
    final query = selectOnly(notificationsTable)
      ..addColumns([countExp])
      ..where(notificationsTable.isDeleted.equals(false));

    if (unreadOnly == true) {
      query.where(notificationsTable.isRead.equals(false));
    }
    if (typeFilters != null && typeFilters.isNotEmpty) {
      query.where(notificationsTable.type.isIn(typeFilters));
    }
    return query.map((row) => row.read(countExp) ?? 0).getSingle();
  }

  Future<void> markAsRead(String id) =>
      (update(notificationsTable)..where((n) => n.id.equals(id)))
          .write(const NotificationRowCompanion(isRead: Value(true)));

  Future<void> markAllAsRead() => update(notificationsTable)
      .write(const NotificationRowCompanion(isRead: Value(true)));

  Future<void> softDelete(String id) =>
      (update(notificationsTable)..where((n) => n.id.equals(id)))
          .write(const NotificationRowCompanion(isDeleted: Value(true)));

  Future<void> pruneOlderThan(DateTime cutoff) =>
      (delete(notificationsTable)
            ..where((n) => n.receivedAt.isSmallerThanValue(cutoff)))
          .go();
}

// ── Events cache table ─────────────────────────────────────────────────────────

@DataClassName('CachedEvent')
class EventsCache extends Table {
  TextColumn get id => text()();
  TextColumn get dataJson => text()();
  BoolColumn get isMine =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CachedTicket')
class TicketsCache extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text()();
  TextColumn get dataJson => text()();
  TextColumn get status => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Events DAO ─────────────────────────────────────────────────────────────────

@DriftAccessor(tables: [EventsCache, TicketsCache])
class EventsDao extends DatabaseAccessor<AppDatabase>
    with _$EventsDaoMixin {
  EventsDao(super.db);

  Future<void> upsertEvent(EventsCacheCompanion entry) =>
      into(eventsCache).insertOnConflictUpdate(entry);

  Future<void> upsertTicket(TicketsCacheCompanion entry) =>
      into(ticketsCache).insertOnConflictUpdate(entry);

  Future<CachedEvent?> getEvent(String id) =>
      (select(eventsCache)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<List<CachedEvent>> getMyEvents() =>
      (select(eventsCache)..where((e) => e.isMine.equals(true))
        ..orderBy([(e) => OrderingTerm.desc(e.cachedAt)]))
          .get();

  Future<List<CachedTicket>> getMyTickets() =>
      (select(ticketsCache)
        ..orderBy([(t) => OrderingTerm.desc(t.cachedAt)]))
          .get();

  Future<CachedTicket?> getTicket(String id) =>
      (select(ticketsCache)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<CachedTicket>> getTicketsForEvent(String eventId) =>
      (select(ticketsCache)..where((t) => t.eventId.equals(eventId))).get();

  Future<void> updateTicketStatus(String id, String status) =>
      (update(ticketsCache)..where((t) => t.id.equals(id)))
          .write(TicketsCacheCompanion(status: Value(status)));

  Future<void> pruneEventCache(DateTime olderThan) =>
      (delete(eventsCache)
            ..where((e) => e.cachedAt.isSmallerThanValue(olderThan)))
          .go();
}

// ── Database ───────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [NotificationsTable, EventsCache, TicketsCache],
  daos: [NotificationsDao, EventsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(notificationsTable);
          }
          if (from < 3) {
            await m.createTable(eventsCache);
            await m.createTable(ticketsCache);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'vibyuk.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
