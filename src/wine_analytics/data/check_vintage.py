import pandas as pd
from pathlib import Path

# Путь к очищенному файлу, который создал clean.py
PROJECT_ROOT = Path(__file__).resolve().parents[3]
CLEAN_PATH = PROJECT_ROOT / "data" / "processed" / "wines_clean.csv"

df = pd.read_csv(CLEAN_PATH, index_col=0)

# Сколько строк вообще без года (регулярка ничего не нашла)
print("Строк без года:", df["vintage_year"].isna().sum())

# Минимальный и максимальный год: сразу видно нереальные значения
print("Минимальный год:", df["vintage_year"].min())
print("Максимальный год:", df["vintage_year"].max())

# Как распределены годы: сколько вин на каждый год
print("\nКоличество вин по годам:")
print(df["vintage_year"].value_counts().sort_index())