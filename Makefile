pub_get:
	cd client && flutter pub get
	cd pkg/db_driver/impl/mysql && flutter pub get
	cd pkg/db_driver/impl/pg && flutter pub get
	cd pkg/db_driver && flutter pub get
	cd pkg/sql_parser && flutter pub get
	cd pkg/sql-editor && flutter pub get

dart_gen_code:
	cd client && dart run build_runner build --delete-conflicting-outputs
	cd client && flutter pub run flutter_launcher_icons
	cd client && flutter gen-l10n --verbose

	cd pkg/db_driver/impl/mysql && flutter_rust_bridge_codegen generate