"""
MySQL接続ユーティリティ
NotebookからMySQLに接続するための共通モジュール
"""
import os
from contextlib import contextmanager

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# .env を読み込み
load_dotenv()

def get_engine():
    """SQLAlchemy Engine を取得する"""
    user = os.getenv("MYSQL_USER", "root")
    password = os.getenv("MYSQL_PASSWORD", "")
    host = os.getenv("MYSQL_HOST", "localhost")
    port = os.getenv("MYSQL_PORT", "3306")
    database = os.getenv("MYSQL_DATABASE", "ma_matching")

    url = f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}?charset=utf8mb4"
    return create_engine(url, echo=False)


def query(sql: str, params: dict = None) -> pd.DataFrame:
    """SQLを実行してDataFrameで返す"""
    engine = get_engine()
    with engine.connect() as conn:
        return pd.read_sql(text(sql), conn, params=params)


def execute(sql: str, params: dict = None):
    """INSERT/UPDATE/DELETE を実行する"""
    engine = get_engine()
    with engine.begin() as conn:
        conn.execute(text(sql), params or {})


def insert_dataframe(df: pd.DataFrame, table_name: str, if_exists: str = "append"):
    """DataFrameをテーブルに一括挿入する"""
    engine = get_engine()
    df.to_sql(table_name, engine, if_exists=if_exists, index=False, method="multi", chunksize=500)


def test_connection():
    """接続テスト"""
    try:
        result = query("SELECT 1 AS ok")
        print("✅ MySQL接続成功!")

        # テーブル一覧
        tables = query("""
            SELECT TABLE_NAME, TABLE_ROWS
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = 'ma_matching'
            ORDER BY TABLE_NAME
        """)
        print(f"\n📋 テーブル数: {len(tables)}")
        print(tables.to_string(index=False))
        return True
    except Exception as e:
        print(f"❌ MySQL接続失敗: {e}")
        print("\n確認事項:")
        print("  1. MySQLサーバーが起動しているか")
        print("  2. .env のユーザー名・パスワードが正しいか")
        print("  3. ma_matching データベースが作成済みか")
        return False


if __name__ == "__main__":
    test_connection()
