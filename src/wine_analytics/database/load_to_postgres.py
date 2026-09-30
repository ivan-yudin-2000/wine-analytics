import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

# Загружаем переменные из .env в окружение процесса
load_dotenv()

PROJECT_ROOT = Path(__file__).resolve().parents[3]
CLEAN_PATH = PROJECT_ROOT / "data" / "processed" / "wines_clean.csv"

# Собираем строку подключения к базе из переменных .env
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")

connection_string = f"postgresql+psycopg://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
engine = create_engine(connection_string)
# Читаем очищенные данные
df = pd.read_csv(CLEAN_PATH, index_col=0)
print(f"Загружаем в базу {len(df)} строк...")

# Заливаем таблицу в Postgres
df.to_sql("wines", engine, if_exists="replace", index=False)
print("Готово. Таблица 'wines' создана/обновлена в базе wine_analytics.")