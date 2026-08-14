/// Vai trò người dùng
enum UserRole { htx, buyer;
  static UserRole fromString(String v) =>
      UserRole.values.firstWhere((e) => e.name == v, orElse: () => UserRole.buyer);
}

/// Trạng thái đơn hàng
enum OrderStatus {
  pendingConfirm,   // Chờ xác nhận
  confirmed,        // Đã xác nhận
  waitingShip,      // Chờ vận chuyển
  inTransit,        // Đang vận chuyển
  completed,        // Hoàn thành
  cancelled;        // Đã hủy

  String get displayName {
    const m = {
      OrderStatus.pendingConfirm: 'Chờ xác nhận',
      OrderStatus.confirmed:      'Đã xác nhận',
      OrderStatus.waitingShip:    'Chờ vận chuyển',
      OrderStatus.inTransit:      'Đang vận chuyển',
      OrderStatus.completed:      'Hoàn thành',
      OrderStatus.cancelled:      'Đã hủy',
    };
    return m[this]!;
  }

  String get tone {
    const m = {
      OrderStatus.pendingConfirm: 'yellow',
      OrderStatus.confirmed:      'blue',
      OrderStatus.waitingShip:    'lilac',
      OrderStatus.inTransit:      'blue',
      OrderStatus.completed:      'green',
      OrderStatus.cancelled:      'red',
    };
    return m[this]!;
  }

  static OrderStatus fromString(String v) {
    const m = {
      'pending_confirm': OrderStatus.pendingConfirm,
      'confirmed':       OrderStatus.confirmed,
      'waiting_ship':    OrderStatus.waitingShip,
      'in_transit':      OrderStatus.inTransit,
      'completed':       OrderStatus.completed,
      'cancelled':       OrderStatus.cancelled,
    };
    return m[v] ?? OrderStatus.pendingConfirm;
  }

  String toStorage() {
    const m = {
      OrderStatus.pendingConfirm: 'pending_confirm',
      OrderStatus.confirmed:      'confirmed',
      OrderStatus.waitingShip:    'waiting_ship',
      OrderStatus.inTransit:      'in_transit',
      OrderStatus.completed:      'completed',
      OrderStatus.cancelled:      'cancelled',
    };
    return m[this]!;
  }
}

/// Trạng thái lô hàng
enum LotStatus {
  draft, active, checking, sold, expired;

  String get displayName {
    const m = {
      LotStatus.draft:    'Bản nháp',
      LotStatus.active:   'Đang bán',
      LotStatus.checking: 'Chờ kiểm tra',
      LotStatus.sold:     'Đã bán',
      LotStatus.expired:  'Hết hạn',
    };
    return m[this]!;
  }

  String get tone {
    const m = {
      LotStatus.draft:    'gray',
      LotStatus.active:   'green',
      LotStatus.checking: 'yellow',
      LotStatus.sold:     'blue',
      LotStatus.expired:  'red',
    };
    return m[this]!;
  }

  static LotStatus fromString(String v) =>
      LotStatus.values.firstWhere((e) => e.name == v, orElse: () => LotStatus.draft);
}

/// Chất lượng tồn kho
enum InventoryQuality { good, urgent, rejected;
  String get displayName {
    const m = {
      InventoryQuality.good:     'Còn tốt',
      InventoryQuality.urgent:   'Cần bán sớm',
      InventoryQuality.rejected: 'Không đạt',
    };
    return m[this]!;
  }
  String get tone {
    const m = {
      InventoryQuality.good:     'green',
      InventoryQuality.urgent:   'orange',
      InventoryQuality.rejected: 'red',
    };
    return m[this]!;
  }
}
