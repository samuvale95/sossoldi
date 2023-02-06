import '../database/sossoldi_database.dart';
import '../model/category_transaction.dart';
import 'base_entity.dart';

const String budgetTable = 'budget';

class BudgetFields extends BaseEntityFields {
  static String id = BaseEntityFields.getId;
  static String name = 'name';
  static String idCategory = 'idCategory'; // FK
  static String amountLimit = 'amountLimit';
  static String createdAt = BaseEntityFields.getCreatedAt;
  static String updatedAt = BaseEntityFields.getUpdatedAt;

  static final List<String> allFields = [
    BaseEntityFields.id,
    idCategory,
    amountLimit,
    name,
    BaseEntityFields.createdAt,
    BaseEntityFields.updatedAt
  ];
}

class Budget extends BaseEntity {
  final int idCategory;
  final num amountLimit;
  final String? name;

  const Budget(
      {int? id,
      required this.idCategory,
      required this.amountLimit,
      String? this.name,
      DateTime? createdAt,
      DateTime? updatedAt})
      : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  Budget copy(
          {int? id,
          int? idCategory,
          num? amountLimit,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Budget(
          id: id ?? this.id,
          idCategory: idCategory ?? this.idCategory,
          amountLimit: amountLimit ?? this.amountLimit,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt);

  static Budget fromJson(Map<String, Object?> json) => Budget(
      id: json[BaseEntityFields.id] as int?,
      idCategory: json[BudgetFields.idCategory] as int,
      name: json[BudgetFields.name] as String?,
      amountLimit: json[BudgetFields.amountLimit] as num,
      createdAt: DateTime.parse(json[BaseEntityFields.createdAt] as String),
      updatedAt: DateTime.parse(json[BaseEntityFields.updatedAt] as String));

  Map<String, Object?> toJson() => {
        BaseEntityFields.id: id,
        BudgetFields.idCategory: idCategory,
        BudgetFields.amountLimit: amountLimit,
        BaseEntityFields.createdAt: createdAt?.toIso8601String(),
        BaseEntityFields.updatedAt: updatedAt?.toIso8601String(),
      };
}

class BudgetMethods extends SossoldiDatabase {
  Future<Budget> insert(Budget item) async {
    final database = await SossoldiDatabase.instance.database;
    final id = await database.insert(budgetTable, item.toJson());
    return item.copy(id: id);
  }


  Future<Budget> selectById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    final maps = await database.query(
      budgetTable,
      columns: BudgetFields.allFields,
      where: '${BudgetFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Budget>> selectAll() async {
    final database = await SossoldiDatabase.instance.database;
    final orderByASC = '${BudgetFields.createdAt} ASC';
    final result = await database.rawQuery('SELECT bt.*, ct.name FROM $budgetTable as bt LEFT JOIN $categoryTransactionTable as ct ON bt.${BudgetFields.idCategory} = ct.${CategoryTransactionFields.id} ORDER BY $orderByASC');
    return result.map((json) => Budget.fromJson(json)).toList();
  }

  Future<int> updateItem(Budget item) async {
    final database = await SossoldiDatabase.instance.database;

    // You can use `rawUpdate` to write the query in SQL
    return database.update(
      budgetTable,
      item.toJson(),
      where:
      '${BudgetFields.id} = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteById(int id) async {
    final database = await SossoldiDatabase.instance.database;

    return await database.delete(budgetTable,
        where:
        '${BudgetFields.id} = ?',
        whereArgs: [id]);
  }

}