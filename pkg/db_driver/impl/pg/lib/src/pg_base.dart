library;

import 'package:postgres/postgres.dart';

class PGConn {
  Connection conn;

  PGConn(this.conn);

  static Future<PGConn> open({
    required Endpoint endpoint,
    Duration? connectTimeout,
    Duration? queryTimeout,
  }) async {
    final conn = await Connection.open(endpoint,
        settings: ConnectionSettings(
          sslMode: SslMode.disable, //todo: 需要判断是否需要开启ssl
          connectTimeout: connectTimeout,
          queryTimeout: queryTimeout,
        ));
    return PGConn(conn);
  }

  Future<Result> query({required String query}) async {
    return conn.execute(query);
  }

  Future<void> close() {
    return conn.close();
  }
}
