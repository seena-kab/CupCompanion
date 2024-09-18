// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_drink.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteDrinkAdapter extends TypeAdapter<FavoriteDrink> {
  @override
  final int typeId = 3;

  @override
  FavoriteDrink read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteDrink(
      drink: fields[0] as Drink,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteDrink obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.drink);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteDrinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
