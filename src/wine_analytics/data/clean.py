import pandas as pd
from pathlib import Path

# Находим корень проекта от расположения этого файла
PROJECT_ROOT = Path(__file__).resolve().parents[3]
RAW_PATH = PROJECT_ROOT / "data" / "raw" / "winemag-data-130k-v2.csv"
PROCESSED_PATH = PROJECT_C:\Users\Admin\Desktop\pet-2\wine-analytics\.venv\Scripts\python.exe C:\Users\Admin\Desktop\pet-2\wine-analytics\src\wine_analytics\data\clean.py
Загружено строк: 129971
После удаления строк без country/province/variety: 129907
Удалено дубликатов: 9979
Сохранено в: C:\Users\Admin\Desktop\pet-2\wine-analytics\data\processed\wines_clean.csv
Итоговый размер: (119928, 14)

Process finished with exit code 0
ROOT / "data" / "processed" / "wines_clean.csv"

# 1. Загружаем сырые данные
df = pd.read_csv(RAW_PATH, index_col=0)
print(f"Загружено строк: {len(df)}")

# 2. Удаляем строки где нет критичных для анализа полей
df = df.dropna(subset=["country", "province", "variety"])
print(f"После удаления строк без country/province/variety: {len(df)}")

# 3. Убираем возможные полные дубликаты строк
before = len(df)
df = df.drop_duplicates()
print(f"Удалено дубликатов: {before - len(df)}")

# 4. Извлекаем год урожая из title (например, "Opus One 2013 Cabernet..." -> 2013)
df["vintage_year"] = df["title"].str.extract(r"(\d{4})")
df["vintage_year"] = pd.to_numeric(df["vintage_year"], errors="coerce")

# 5. Сохраняем результат
PROCESSED_PATH.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(PROCESSED_PATH)
print(f"Сохранено в: {PROCESSED_PATH}")
print(f"Итоговый размер: {df.shape}")