{-|
Module: IHP.IDE.SchemaDesigner.Compiler
Description: Compiles AST of SQL to DDL
Copyright: (c) digitally induced GmbH, 2020
-}
module IHP.IDE.SchemaDesigner.Compiler (compileSql, writeSchema, reservedKeywordEscaper) where

import IHP.Prelude
import IHP.IDE.SchemaDesigner.Types
import Data.Maybe (fromJust)
import qualified Data.Text.IO as Text

writeSchema :: [Statement] -> IO ()
writeSchema !statements = do
    let sortedStatements = sortBy compareStatement statements
    Text.writeFile "Application/Schema.sql" (compileSql sortedStatements)

compileSql :: [Statement] -> Text
compileSql statements = statements
    |> map compileStatement
    |> unlines

compileStatement :: Statement -> Text
compileStatement CreateTable { name, columns } = "CREATE TABLE " <> reservedKeywordEscaper name <> " (\n" <> intercalate ",\n" (map compileColumn columns) <> "\n);"
compileStatement CreateEnumType { name, values } = "CREATE TYPE " <> reservedKeywordEscaper name <> " AS ENUM (" <> intercalate ", " values <> ");"
compileStatement CreateExtension { name, ifNotExists } = "CREATE EXTENSION " <> (if ifNotExists then "IF NOT EXISTS " else "") <> "\"" <> reservedKeywordEscaper name <> "\";"
compileStatement AddConstraint { tableName, constraintName, constraint } = "ALTER TABLE " <> reservedKeywordEscaper tableName <> " ADD CONSTRAINT " <> reservedKeywordEscaper constraintName <> " " <> compileConstraint constraint <> ";"
compileStatement Comment { content } = "-- " <> content
compileStatement UnknownStatement { raw } = raw

compileConstraint :: Constraint -> Text
compileConstraint ForeignKeyConstraint { columnName, referenceTable, referenceColumn, onDelete } = "FOREIGN KEY (" <> reservedKeywordEscaper columnName <> ") REFERENCES " <> reservedKeywordEscaper referenceTable <> (if isJust referenceColumn then " (" <> fromJust referenceColumn <> ")" else "") <> " " <> compileOnDelete onDelete

compileOnDelete :: Maybe OnDelete -> Text
compileOnDelete Nothing = ""
compileOnDelete (Just NoAction) = "ON DELETE NO ACTION"
compileOnDelete (Just Restrict) = "ON DELETE RESTRICT"
compileOnDelete (Just SetNull) = "ON DELETE SET NULL"
compileOnDelete (Just Cascade) = "ON DELETE CASCADE"

compileColumn :: Column -> Text
compileColumn Column { name, columnType, primaryKey, defaultValue, notNull, isUnique } =
    "    " <> unwords (catMaybes
        [ Just (reservedKeywordEscaper name)
        , Just columnType
        , fmap compileDefaultValue defaultValue
        , if primaryKey then Just "PRIMARY KEY" else Nothing
        , if notNull then Just "NOT NULL" else Nothing
        , if isUnique then Just "UNIQUE" else Nothing
        ])

compileDefaultValue :: Text -> Text
compileDefaultValue value = "DEFAULT " <> value

compareStatement (CreateTable {}) _ = LT
compareStatement (AddConstraint {}) _ = GT
compareStatement _ _ = EQ

reservedKeywordEscaper :: _ -> Text
reservedKeywordEscaper keyword = case (IHP.Prelude.toUpper keyword) of
    "ABORT" -> tshow "ABORT"
    "ABSOLUTE" -> tshow "ABSOLUTE"
    "ACCESS" -> tshow "ACCESS"
    "ACTION" -> tshow "ACTION"
    "ADD" -> tshow "ADD"
    "ADMIN" -> tshow "ADMIN"
    "AFTER" -> tshow "AFTER"
    "AGGREGATE" -> tshow "AGGREGATE"
    "ALSO" -> tshow "ALSO"
    "ALTER" -> tshow "ALTER"
    "ASSERTION" -> tshow "ASSERTION"
    "ASSIGNMENT" -> tshow "ASSIGNMENT"
    "AT" -> tshow "AT"
    "BACKWARD" -> tshow "BACKWARD"
    "BEFORE" -> tshow "BEFORE"
    "BEGIN" -> tshow "BEGIN"
    "BY" -> tshow "BY"
    "CACHE" -> tshow "CACHE"
    "CALLED" -> tshow "CALLED"
    "CASCADE" -> tshow "CASCADE"
    "CHAIN" -> tshow "CHAIN"
    "CHARACTERISTICS" -> tshow "CHARACTERISTICS"
    "CHECKPOINT" -> tshow "CHECKPOINT"
    "CLASS" -> tshow "CLASS"
    "CLOSE" -> tshow "CLOSE"
    "CLUSTER" -> tshow "CLUSTER"
    "COMMENT" -> tshow "COMMENT"
    "COMMIT" -> tshow "COMMIT"
    "COMMITTED" -> tshow "COMMITTED"
    "CONNECTION" -> tshow "CONNECTION"
    "CONSTRAINTS" -> tshow "CONSTRAINTS"
    "CONVERSION" -> tshow "CONVERSION"
    "COPY" -> tshow "COPY"
    "CREATEDB" -> tshow "CREATEDB"
    "CREATEROLE" -> tshow "CREATEROLE"
    "CREATEUSER" -> tshow "CREATEUSER"
    "CSV" -> tshow "CSV"
    "CURSOR" -> tshow "CURSOR"
    "CYCLE" -> tshow "CYCLE"
    "DATABASE" -> tshow "DATABASE"
    "DAY" -> tshow "DAY"
    "DEALLOCATE" -> tshow "DEALLOCATE"
    "DECLARE" -> tshow "DECLARE"
    "DEFAULTS" -> tshow "DEFAULTS"
    "DEFERRED" -> tshow "DEFERRED"
    "DEFINER" -> tshow "DEFINER"
    "DELETE" -> tshow "DELETE"
    "DELIMITER" -> tshow "DELIMITER"
    "DELIMITERS" -> tshow "DELIMITERS"
    "DISABLE" -> tshow "DISABLE"
    "DOMAIN" -> tshow "DOMAIN"
    "DOUBLE" -> tshow "DOUBLE"
    "DROP" -> tshow "DROP"
    "EACH" -> tshow "EACH"
    "ENABLE" -> tshow "ENABLE"
    "ENCODING" -> tshow "ENCODING"
    "ENCRYPTED" -> tshow "ENCRYPTED"
    "ESCAPE" -> tshow "ESCAPE"
    "EXCLUDING" -> tshow "EXCLUDING"
    "EXCLUSIVE" -> tshow "EXCLUSIVE"
    "EXECUTE" -> tshow "EXECUTE"
    "EXPLAIN" -> tshow "EXPLAIN"
    "EXTERNAL" -> tshow "EXTERNAL"
    "FETCH" -> tshow "FETCH"
    "FIRST" -> tshow "FIRST"
    "FORCE" -> tshow "FORCE"
    "FORWARD" -> tshow "FORWARD"
    "FUNCTION" -> tshow "FUNCTION"
    "GLOBAL" -> tshow "GLOBAL"
    "GRANTED" -> tshow "GRANTED"
    "HANDLER" -> tshow "HANDLER"
    "HEADER" -> tshow "HEADER"
    "HOLD" -> tshow "HOLD"
    "HOUR" -> tshow "HOUR"
    "IMMEDIATE" -> tshow "IMMEDIATE"
    "IMMUTABLE" -> tshow "IMMUTABLE"
    "IMPLICIT" -> tshow "IMPLICIT"
    "INCLUDING" -> tshow "INCLUDING"
    "INCREMENT" -> tshow "INCREMENT"
    "INDEX" -> tshow "INDEX"
    "INHERIT" -> tshow "INHERIT"
    "INHERITS" -> tshow "INHERITS"
    "INPUT" -> tshow "INPUT"
    "INSENSITIVE" -> tshow "INSENSITIVE"
    "INSERT" -> tshow "INSERT"
    "INSTEAD" -> tshow "INSTEAD"
    "INVOKER" -> tshow "INVOKER"
    "ISOLATION" -> tshow "ISOLATION"
    "KEY" -> tshow "KEY"
    "LANCOMPILER" -> tshow "LANCOMPILER"
    "LANGUAGE" -> tshow "LANGUAGE"
    "LARGE" -> tshow "LARGE"
    "LAST" -> tshow "LAST"
    "LEVEL" -> tshow "LEVEL"
    "LISTEN" -> tshow "LISTEN"
    "LOAD" -> tshow "LOAD"
    "LOCAL" -> tshow "LOCAL"
    "LOCATION" -> tshow "LOCATION"
    "LOCK" -> tshow "LOCK"
    "LOGIN" -> tshow "LOGIN"
    "MATCH" -> tshow "MATCH"
    "MAXVALUE" -> tshow "MAXVALUE"
    "MINUTE" -> tshow "MINUTE"
    "MINVALUE" -> tshow "MINVALUE"
    "MODE" -> tshow "MODE"
    "MONTH" -> tshow "MONTH"
    "MOVE" -> tshow "MOVE"
    "NAMES" -> tshow "NAMES"
    "NEXT" -> tshow "NEXT"
    "NO" -> tshow "NO"
    "NOCREATEDB" -> tshow "NOCREATEDB"
    "NOCREATEROLE" -> tshow "NOCREATEROLE"
    "NOCREATEUSER" -> tshow "NOCREATEUSER"
    "NOINHERIT" -> tshow "NOINHERIT"
    "NOLOGIN" -> tshow "NOLOGIN"
    "NOSUPERUSER" -> tshow "NOSUPERUSER"
    "NOTHING" -> tshow "NOTHING"
    "NOTIFY" -> tshow "NOTIFY"
    "NOWAIT" -> tshow "NOWAIT"
    "OBJECT" -> tshow "OBJECT"
    "OF" -> tshow "OF"
    "OIDS" -> tshow "OIDS"
    "OPERATOR" -> tshow "OPERATOR"
    "OPTION" -> tshow "OPTION"
    "OWNER" -> tshow "OWNER"
    "PARTIAL" -> tshow "PARTIAL"
    "PASSWORD" -> tshow "PASSWORD"
    "PREPARE" -> tshow "PREPARE"
    "PREPARED" -> tshow "PREPARED"
    "PRESERVE" -> tshow "PRESERVE"
    "PRIOR" -> tshow "PRIOR"
    "PRIVILEGES" -> tshow "PRIVILEGES"
    "PROCEDURAL" -> tshow "PROCEDURAL"
    "PROCEDURE" -> tshow "PROCEDURE"
    "QUOTE" -> tshow "QUOTE"
    "READ" -> tshow "READ"
    "RECHECK" -> tshow "RECHECK"
    "REINDEX" -> tshow "REINDEX"
    "RELATIVE" -> tshow "RELATIVE"
    "RELEASE" -> tshow "RELEASE"
    "RENAME" -> tshow "RENAME"
    "REPEATABLE" -> tshow "REPEATABLE"
    "REPLACE" -> tshow "REPLACE"
    "RESET" -> tshow "RESET"
    "RESTART" -> tshow "RESTART"
    "RESTRICT" -> tshow "RESTRICT"
    "RETURNS" -> tshow "RETURNS"
    "REVOKE" -> tshow "REVOKE"
    "ROLE" -> tshow "ROLE"
    "ROLLBACK" -> tshow "ROLLBACK"
    "ROWS" -> tshow "ROWS"
    "RULE" -> tshow "RULE"
    "SAVEPOINT" -> tshow "SAVEPOINT"
    "SCHEMA" -> tshow "SCHEMA"
    "SCROLL" -> tshow "SCROLL"
    "SECOND" -> tshow "SECOND"
    "SECURITY" -> tshow "SECURITY"
    "SEQUENCE" -> tshow "SEQUENCE"
    "SERIALIZABLE" -> tshow "SERIALIZABLE"
    "SESSION" -> tshow "SESSION"
    "SET" -> tshow "SET"
    "SHARE" -> tshow "SHARE"
    "tshow" -> tshow "tshow"
    "SIMPLE" -> tshow "SIMPLE"
    "STABLE" -> tshow "STABLE"
    "START" -> tshow "START"
    "STATEMENT" -> tshow "STATEMENT"
    "STATISTICS" -> tshow "STATISTICS"
    "STDIN" -> tshow "STDIN"
    "STDOUT" -> tshow "STDOUT"
    "STORAGE" -> tshow "STORAGE"
    "STRICT" -> tshow "STRICT"
    "SUPERUSER" -> tshow "SUPERUSER"
    "SYSID" -> tshow "SYSID"
    "SYSTEM" -> tshow "SYSTEM"
    "TABLESPACE" -> tshow "TABLESPACE"
    "TEMP" -> tshow "TEMP"
    "TEMPLATE" -> tshow "TEMPLATE"
    "TEMPORARY" -> tshow "TEMPORARY"
    "TOAST" -> tshow "TOAST"
    "TRANSACTION" -> tshow "TRANSACTION"
    "TRIGGER" -> tshow "TRIGGER"
    "TRUNCATE" -> tshow "TRUNCATE"
    "TRUSTED" -> tshow "TRUSTED"
    "TYPE" -> tshow "TYPE"
    "UNCOMMITTED" -> tshow "UNCOMMITTED"
    "UNENCRYPTED" -> tshow "UNENCRYPTED"
    "UNKNOWN" -> tshow "UNKNOWN"
    "UNLISTEN" -> tshow "UNLISTEN"
    "UNTIL" -> tshow "UNTIL"
    "UPDATE" -> tshow "UPDATE"
    "VACUUM" -> tshow "VACUUM"
    "VALID" -> tshow "VALID"
    "VALIDATOR" -> tshow "VALIDATOR"
    "VALUES" -> tshow "VALUES"
    "VARYING" -> tshow "VARYING"
    "VIEW" -> tshow "VIEW"
    "VOLATILE" -> tshow "VOLATILE"
    "WITH" -> tshow "WITH"
    "WITHOUT" -> tshow "WITHOUT"
    "WORK" -> tshow "WORK"
    "WRITE" -> tshow "WRITE"
    "YEAR" -> tshow "YEAR"
    "ZONE" -> tshow "ZONE"
    "BIGINT" -> tshow "BIGINT"
    "BIT" -> tshow "BIT"
    "BOOLEAN" -> tshow "BOOLEAN"
    "CHAR" -> tshow "CHAR"
    "CHARACTER" -> tshow "CHARACTER"
    "COALESCE" -> tshow "COALESCE"
    "CONVERT" -> tshow "CONVERT"
    "DEC" -> tshow "DEC"
    "DECIMAL" -> tshow "DECIMAL"
    "EXISTS" -> tshow "EXISTS"
    "EXTRACT" -> tshow "EXTRACT"
    "FLOAT" -> tshow "FLOAT"
    "GREATEST" -> tshow "GREATEST"
    "INOUT" -> tshow "INOUT"
    "INT" -> tshow "INT"
    "INTEGER" -> tshow "INTEGER"
    "INTERVAL" -> tshow "INTERVAL"
    "LEAST" -> tshow "LEAST"
    "NATIONAL" -> tshow "NATIONAL"
    "NCHAR" -> tshow "NCHAR"
    "NONE" -> tshow "NONE"
    "NULLIF" -> tshow "NULLIF"
    "NUMERIC" -> tshow "NUMERIC"
    "OUT" -> tshow "OUT"
    "OVERLAY" -> tshow "OVERLAY"
    "POSITION" -> tshow "POSITION"
    "PRECISION" -> tshow "PRECISION"
    "REAL" -> tshow "REAL"
    "ROW" -> tshow "ROW"
    "SETOF" -> tshow "SETOF"
    "SMALLINT" -> tshow "SMALLINT"
    "SUBSTRING" -> tshow "SUBSTRING"
    "TIME" -> tshow "TIME"
    "TIMESTAMP" -> tshow "TIMESTAMP"
    "TREAT" -> tshow "TREAT"
    "TRIM" -> tshow "TRIM"
    "VARCHAR" -> tshow "VARCHAR"
    _ -> cs keyword
    