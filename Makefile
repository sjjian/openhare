dart_gen_code:
	cd client && dart run build_runner build --delete-conflicting-outputs
	cd client && flutter pub run flutter_launcher_icons
	cd client && flutter gen-l10n --verbose

	cd pkg/db_driver/impl/mysql && flutter_rust_bridge_codegen generate