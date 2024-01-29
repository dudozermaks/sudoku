class Pos {
  int x;
  int y;

  Pos(this.x, this.y);

  Pos.fromJson(Map<String, dynamic> json)
      : x = json["x"] as int,
        y = json["y"] as int;

  @override
  int get hashCode => toIndex();

  @override
  bool operator ==(Object other) =>
      other is Pos && other.x == x && other.y == y;

  Pos operator *(int n) => Pos(x * n, y * n);
  Pos operator +(Pos p) => Pos(x + p.x, y + p.y);

  bool isValidIndex() {
    int index = toIndex();
    return index >= 0 && index < 81;
  }

  int toIndex() => x + y * 9;

  @override
  String toString() => "x: $x, y: $y";

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}
