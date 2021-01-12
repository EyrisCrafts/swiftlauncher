class IconPack {
  String name;
  String packageName;
  IconPack({
    this.name,
    this.packageName,
  });

  String get getName => name;

  set setName(String name) => this.name = name;

  String get getPackageName => packageName;

  set setPackageName(String packageName) => this.packageName = packageName;
}
