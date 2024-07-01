
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:smartbike_flutter/features/my_bikes/domain/bike_entity/bike_model/bike_model.dart';
import 'package:smartbike_flutter/smartbike_database/smartbike_db.dart';
import 'package:sqflite/sqflite.dart';



final databaseProvider = Provider<SmartBikeDatabase>((_) => SmartBikeDatabaseImpl());

class SmartBikeDatabaseImpl implements SmartBikeDatabase{

  static const _databaseName = 'SBMConnect_database.db';
  static const _databaseVersion = 2;

  static const _tableBikeData = 'BikeData';
  static const _tableSBMData = 'SBMData';

  ///Table BikeData Attributes
  static const _columnBikeId = 'id';
  static const _columnBikeName = 'name';
  static const _columnFriendlyName = 'friendlyName';
  static const _columnUserMappings = 'user_mappings';
  static const _columnModelName = 'model_name';
  static const _columnTenantId = 'tenant_id';
  static const _columnMappedLocality = 'mapped_locality';
  static const _columnMappedCity = 'mapped_city';
  static const _columnMappedCountry = 'mapped_country';
  static const _columnSbmMappings = 'sbm_mappings';
  static const _columnKeyfobMapping = 'keyfob_mappings';
  static const _columnCreatedBy = 'created_by';
  static const _columnUpdatedBy = 'updated_by';
  static const _columnCreatedAt = 'created_at';
  static const _columnUpdatedAt = 'updated_at';
  static const _columnIsActive = 'is_active';
  static const _columnStatusId = 'status_id';


  ///Table SBMData Attributes
  static const _columnForeignKey = 'bikeDataId';
  static const _columnBikeLastState = 'bike_last_state';
  static const _columnLastParkedLocation = 'last_parked_location';
  static const _columnLastKnownLocation = 'last_known_location';


  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Initialize the DB first time it is accessed
    _database = await _initDB();
    return _database!;
  }

  Future<Batch> get batch async {
    if (_database != null) {
      return _database!.batch();
    }
    // if _database is null we instantiate it
    _database = await _initDB();
    return _database!.batch();
  }

  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return await openDatabase(
        path,
        onCreate: _onCreate, version: _databaseVersion,
        onUpgrade: (db, oldVersion, newVersion) async{
          log('onUpgrade : $oldVersion $newVersion');
          if (oldVersion < newVersion) {
            await db.execute('ALTER TABLE $_tableBikeData ADD COLUMN $_columnFriendlyName TEXT');
          }
        }
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE $_tableBikeData (
        $_columnBikeId INTEGER PRIMARY KEY,
        $_columnBikeName TEXT NOT NULL,
        $_columnFriendlyName TEXT,
        $_columnTenantId INTEGER,
        $_columnMappedLocality INTEGER,
        $_columnMappedCity INTEGER,
        $_columnMappedCountry INTEGER,
        $_columnIsActive INTEGER NOT NULL,
        $_columnModelName TEXT NOT NULL,
        $_columnStatusId TEXT,
        $_columnUserMappings TEXT NOT NULL,
        $_columnSbmMappings TEXT,
        $_columnKeyfobMapping TEXT,
        $_columnCreatedBy INTEGER,
        $_columnUpdatedBy TEXT,
        $_columnUpdatedAt INTEGER,
        $_columnCreatedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableSBMData (
        $_columnForeignKey INTEGER PRIMARY KEY,
        $_columnBikeLastState INTEGER,
        $_columnLastParkedLocation TEXT,
        $_columnLastKnownLocation TEXT,
        FOREIGN KEY ($_columnForeignKey) REFERENCES $_tableBikeData($_columnBikeId)
      )
    ''');
  }



  @override
  Future<List<Map<String, dynamic>>> getAllBikes() async{
    final db = await database;
    String selectQuery = 'SELECT * FROM $_tableBikeData';
    return db.rawQuery(selectQuery);
  }

  @override
  Future<int> insertAllBikes(final List<BikeData> allBikesList) async{

    final db = await database;
    int bikeDataId = 0;

    await db.transaction((txn) async {

      for(final bikeData in allBikesList){

        // Insert data into BikeData table
        Map<String, dynamic> bikeDataMap = bikeData.toJson();
        bikeDataId = await txn.insert(_tableBikeData, bikeDataMap);
      }
      return bikeDataId;
    });

    return 0;

  }

  @override
  Future<void> deleteAllBikes() async{
    final db = await database;
    await db.delete('BikeData');
  }

  Future<bool> _sbmDataExists(final int bikeId) async{
    final db = await database;

    final queryResult = await db.rawQuery('SELECT * FROM $_tableSBMData WHERE $_columnForeignKey = ?', [bikeId]);
    if(queryResult.isNotEmpty){
      log('sbmData_exists');
      return true;
    }else{
      log('sbmData_not_exists');
      return false;
    }
  }

  @override
  Future<void> updateBikeState(int bikeId, int newBikeState) async{
    final db = await database;

    final sbmDataExists = await _sbmDataExists(bikeId);

    if(sbmDataExists){
      await db.update(_tableSBMData, {_columnBikeLastState: newBikeState}, where: '$_columnForeignKey = ?', whereArgs: [bikeId],);
    }else{
      await db.insert('$_tableSBMData', {'$_columnForeignKey': bikeId, '$_columnBikeLastState': newBikeState});
    }
  }

  @override
  Future<void> updateBikeLastParkedLocation(int bikeId,String bikeLastParkedLocation) async{
    final db = await database;

    final sbmDataExists = await _sbmDataExists(bikeId);

    if(sbmDataExists){
      await db.update(_tableSBMData, {_columnLastParkedLocation: bikeLastParkedLocation}, where: '$_columnForeignKey = ?', whereArgs: [bikeId],);
    }else{
      await db.insert('$_tableSBMData', {'$_columnForeignKey': bikeId, '$_columnLastParkedLocation': bikeLastParkedLocation});
    }
  }

  @override
  Future<int> getBikeLastState(int bikeId) async{
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('$_tableSBMData', columns: ['$_columnBikeLastState'], where: '$_columnForeignKey = ?', whereArgs: [bikeId]);

    if (result.isNotEmpty && result.first['$_columnBikeLastState'] != null) {
      return result.first['$_columnBikeLastState'] as int;
    }
    return -1;
  }

  @override
  Future<String> getBikeLastParkedLocation(int bikeId) async{
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('$_tableSBMData', columns: ['$_columnLastParkedLocation'], where: '$_columnForeignKey = ?', whereArgs: [bikeId]);
    if (result.isNotEmpty && result.first['$_columnLastParkedLocation'] != null) {
      final locationData = result.first['$_columnLastParkedLocation'];
      return locationData as String;
    }
    return '';
  }
}