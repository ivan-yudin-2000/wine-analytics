import pandas as pd
from pathlib import Path

# Находим корень проекта от расположения этого файла
PROJECT_ROOT = Path(__file__).resolve().parents[3]
RAW_PATH = PROJECT_ROOT / "data" / "raw" / "winemag-data-130k-v2.csv"
PROCESSED_PATH = PROJECT_ROOT / "data" / "processed" / "wines_clean.csv"

# 1. Загружаем сырые данные
df = pd.read_csv(RAW_PATH, index_col=0)
print(f"Загружено строк: {len(df)}")

# 2. Удаляем строки, где нет критичных для анализа полей
df = df.dropna(subset=["country", "province", "variety"])
print(f"После удаления строк без country/province/variety: {len(df)}")

# 3. Убираем полные дубликаты строк
before = len(df)
df = df.drop_duplicates()
print(f"Удалено дубликатов: {before - len(df)}")

# 4. Извлекаем год урожая из title (первые 4 цифры подряд)
df["vintage_year"] = df["title"].str.extract(r"(\d{4})")
df["vintage_year"] = pd.to_numeric(df["vintage_year"], errors="coerce")

# Если год вне реального диапазона, заменяем его на пустое значение
mask = (df["vintage_year"] < 1900) | (df["vintage_year"] > 2017)
df.loc[mask, "vintage_year"] = pd.NA

# 5. Сохраняем результат
PROCESSED_PATH.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(PROCESSED_PATH)
print(f"Сохранено в: {PROCESSED_PATH}")
print(f"Итоговый размер: {df.shape}")