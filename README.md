# PostgreSQL14
PostgreSQL integration with WEB-services (PL/Python -> HTTP method GET,POST and send e-mail, PL/pgSQL -> JSON, XML, CSV)

DB PostgreSQL 14 + Python 3.9
IDE - DBeaver

Установка и настройка:
-------------------------------

1) Устанавливаем PostgreSQL 14
2) Создаем базу данных test_database и пользовалеля test_user (скрипты ./1_create_db_and_user/)
3) Включение отладки в PostgreSQL
   - c:\Program Files\PostgreSQL\14\data\postgresql.conf правим файл - меняем
   с
    #shared_preload_libraries = '' # (change requires restart)
   на
    shared_preload_libraries = 'plugin_debugger' # (change requires restart)
   - Перезагрузите сервер, подключиться к БД и вызов:
     - CREATE EXTENSION pldbgapi;

4) Добавление поддержки Python 3 в PostgreSQL
   - Проверить поддерживаему версию Python для PostgreSQL (c:\Program Files\PostgreSQL\14\doc\installation-notes.html)
   - устанавливаем Python python-3.9.XXX-amd64.exe
     -> Install Launcher for all user - включить
     -> Add Python 3.9 to PATH - включить
     -> !!!! Customize installation
     -> NEXT
     -> !!!! Install for all users - включить
     -> Disable MAX_LIMIT - выполнить.
     -> Завершить
   - Перезагрузить ПК подключиться к БД и вызов:
     - CREATE EXTENSION plpython3u;

5) Backup (pgAdmin 4)
   - Запускаем pgAdmin 4
   - Servers -> Dashboard -> Configure pgAdmin -> Patch -> Binary patch
   - Поле PostgreSQL Binary Path = C:\Program Files\PostgreSQL\14\bin\
   - На базе выполнить Backup

6) Backup (DBeaver)
   - На базе правой клавишей -> Tools -> Backup
   - Хранится в C:\Users\Admin\dump-test_database-202105062020.sql (пример)

Добавление объектов базы данных
-------------------------------
1) Выполняем скрипты
   - ./2_sql_test_schemas/
   - ./3_sql_p_check/
   - ./4_sql_p_convert/
   - ./5_sql_p_interface/
   - ./6_sql_p_service/
   - ./7_sql_public/

